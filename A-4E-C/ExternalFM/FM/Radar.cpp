#include "Radar.h"
#include "Maths.h"
#include "Commands.h"
#include <math.h>
#include "cockpit_base_api.h"
#include "Devices.h"

//TODO Rewrite this pile of shit.

constexpr double y1Gain = 0.02;
constexpr double x1Gain = 0.0;
constexpr double y2Gain = 6.0;
constexpr double x2Gain = 1.0;

constexpr double c_bGain = (y1Gain * x1Gain - y2Gain * x2Gain) / (y1Gain - y2Gain);
constexpr double c_aGain = y1Gain * x1Gain - c_bGain * y1Gain;


constexpr static size_t c_rays = SIDE_LENGTH * 2;
constexpr static size_t c_raysAG = 7;

constexpr static double c_pulseLength = 1.0e-6;
constexpr static double c_pulseDistance = c_pulseLength * 3.0e8;

constexpr static size_t c_samplesPerFrame = 100;//150;

constexpr static double c_beamSigma = 0.03705865456;
constexpr static double c_SNR = 1.5e-4;

static double f( double x )
{
	return ( 1.0 / ( c_beamSigma * sqrt( 2.0 * PI ) ) ) * exp( -0.5 * pow( x / c_beamSigma, 2.0 ) );
}

Scooter::Radar::Radar( Interface& inter, AircraftState& state ):
	m_scope(inter),
	m_aircraftState(state),
	m_interface(inter),
	m_normal(0.0, c_beamSigma ),
	m_uniform(0.0, 2.0 * PI),
	m_generator(23)
{
	//for ( size_t i = 0; i < SIDE_LENGTH; i++ )
		//m_scanLine[i] = Vec3f();

	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		double x;
		double y;

		indexToScreenCoords( i, x, y );
		m_scope.setBlobPos( i, x, y );
	}

	HMODULE dll = GetModuleHandleA( "worldgeneral.dll" );

	if ( ! dll )
		return;

	m_terrain = *(void**)GetProcAddress( dll, "?globalLand@@3PEAVwTerrain@@EA" );
	printf( "Terrain pointer: %p\n", m_terrain );
}

void Scooter::Radar::zeroInit()
{
	m_disabled = m_interface.getRadarDisabled();

	if ( m_disabled )
		return;

	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_GAIN, 0.85 );
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_BRILLIANCE, 1.0 );
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_DETAIL, 0.3 );
}

void Scooter::Radar::coldInit()
{
	zeroInit();
}

void Scooter::Radar::hotInit()
{
	zeroInit();
}

void Scooter::Radar::airborneInit()
{
	zeroInit();
}

bool Scooter::Radar::handleInput( int command, float value )
{
	if ( m_disabled )
		return false;

	switch ( command )
	{
	case DEVICE_COMMANDS_RADAR_RANGE:
		m_rangeSwitch = (bool)value;
		return true;
	case DEVICE_COMMANDS_RADAR_ANGLE:
		m_angle = -10.0_deg + 25.0_deg * value ;
		return true;
	case DEVICE_COMMANDS_RADAR_AOACOMP:
		m_aoaCompSwitch = (bool)value;
		return true;
	case DEVICE_COMMANDS_RADAR_MODE:
		m_modeSwitch = (State)round(value * 10.0);
		return true;
	case DEVICE_COMMANDS_RADAR_FILTER:
		m_scope.setFilter( ! (bool)value );
		return true;
	case DEVICE_COMMANDS_RADAR_DETAIL:
		m_detail = value * (5.0_deg - 0.5_deg) + 0.5_deg;
		return true;
	case DEVICE_COMMANDS_RADAR_GAIN:
		m_gain = ( 1.0 - value * 0.9999 ); //c_aGain / (value - c_bGain);//(1.0 - value);//
		return true;
	case DEVICE_COMMANDS_RADAR_BRILLIANCE:
		m_brilliance = value;
		return true;
	case DEVICE_COMMANDS_RADAR_STORAGE:
		m_storage = (1.0 - 0.01) * pow(1.0 - value, 3.0) + 0.01;
		return true;
	case DEVICE_COMMANDS_RADAR_PLANPROFILE:
		//This should perhaps be a state change.
		m_planSwitch = ! (bool)value;
		resetDraw();
		m_cleared = false;
		clearScan();

		return true;
	case DEVICE_COMMANDS_RADAR_VOLUME:
		m_obstacleVolume = value;
		return true;
	case DEVICE_COMMANDS_RADAR_ANGLE_AXIS_ABS:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_ANGLE, angleAxisToCommand(value));
		return true;
	}

	return false;
}

void Scooter::Radar::resetDraw()
{
	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		double x;
		double y;

		indexToScreenCoords( i, x, y );
		m_scope.setBlobPos( i, x, y );
	}
}

void Scooter::Radar::update( double dt )
{

	if ( m_disabled )
	{
		clearScan();
		return;
	}

	if ( ! m_interface.getElecMonitoredAC() )
		return;



	//if ( previous == MODE_AG && previous != m_modeSwitch )
		//resetAGDraw();

	State newState = getState();
	
	if ( newState != m_state )
	{
		transitionState( m_state, newState );
		m_state = newState;
	}

	switch ( m_state )
	{
	case STATE_OFF:
		warmup( -0.5 * dt );
		clearScan();
		break;

	case STATE_STBY:
		clearScan();
		break;

	case STATE_SRCH:
		m_scope.setSideRange( 0.0 );
		m_scope.setBottomRange( m_rangeSwitch ? 0.4 : 0.2 );
		m_scale = m_rangeSwitch ? 2.0 : 1.0;
		scanPlan( dt );
		break;

	case STATE_TC_PLAN:
		m_scale = m_rangeSwitch ? 1.0 : 0.5;
		scanPlan( dt );
		m_scope.setSideRange( 0.0 );
		m_scope.setBottomRange( m_rangeSwitch ? 0.2 : 0.1 );
		m_scope.setProfileScribe( RadarScope::OFF );
		break;
	case STATE_TC_PROFILE:
		m_scale = m_rangeSwitch ? 1.0 : 0.5;
		scanProfile( dt );
		m_scope.setSideRange( m_rangeSwitch ? 0.2 : 0.1 );
		m_scope.setBottomRange( 0.0 );
		drawScanProfile();
		m_scope.setProfileScribe( m_rangeSwitch ? RadarScope::ON_20 : RadarScope::ON_10 );
		break;

	case STATE_AG:
		m_scale = 20000.0_yard / 20.0_nauticalMile;
		scanAG( dt );
		drawScanAG();
		break;
	}


	warmup( dt );

	updateObstacleLight(dt);
	m_scope.setObstacle( m_obstacleIndicator && (m_obstacleCount > 0), m_obstacleVolume );
	m_scope.update( dt );
	
}

void Scooter::Radar::updateGimbalPlan()
{
	//Update the
	m_sweepAngle = m_angle;
	m_xIndex += m_direction;

	if ( m_xIndex >= (SIDE_LENGTH - 1) )
	{
		m_xIndex = (SIDE_LENGTH - 1);
		m_direction = -1;
	}
	else if ( m_xIndex <= 0 )
	{
		m_xIndex = 0;
		m_direction = 1;
	}
}

void Scooter::Radar::resetScanData()
{
	for ( size_t i = 0; i < SIDE_LENGTH; i++ )
	{
		m_scanIntensity[i] = 0.0;
		m_scanAngle[i] = -10000.0;
	}
}

void Scooter::Radar::scanPlan( double dt )
{
	constexpr int framesPerAzimuth = 4;
	m_scanned = (m_scanned + 1) % framesPerAzimuth;

	if ( m_scanned == 0 )
	{
		//Sweep this big 'ol torch left and right.
		updateGimbalPlan();

		//We don't care about the obs light in plan mode.
		resetObstacleData();

		//Reset data for this line.
		resetScanData();
	}

	// Collected all data so draw the scan now.
	if ( m_scanned == (framesPerAzimuth - 1) )
		drawScan();

	// What the fuck has gone wrong.
	// I would crash it here but, people
	// can still fly it without the radar.
	if ( ! m_terrain )
		return;

	
	
	
	scanOneLine2(m_state == STATE_TC_PLAN);
}

void Scooter::Radar::scanOneLine3( bool detail )
{
	float x = 1.0 - 2.0 * (float)m_xIndex / (float)SIDE_LENGTH;
	double yawAngle = x * 30.0_deg;

	double range = 0.0;

	double theta = 0.0;

	for ( size_t i = 0; i < c_samplesPerFrame; i++ )
	{
		double phi = m_uniform( m_generator );

		double xRay = theta * cos( phi );
		double pitchAngle = theta * sin( phi );

		//float y = -1.0 + 2.0 * (float)i / (float)c_rays;
		//double pitchAngle = 2.5_deg * y;

		if ( ! detail || abs( pitchAngle ) <= m_detail )
		{
			if ( scanOneRay( pitchAngle, xRay + yawAngle, range ) )
			{
				//If there is a possible obstacle then record this info.
				setObstacle( range );
			}
		}

		theta += 0.02 / f( theta );
	}

	printf( "%lf\n", theta );
}

void Scooter::Radar::scanOneLine2( bool detail )
{
	float x = 1.0 - 2.0 * (float)m_xIndex / (float)SIDE_LENGTH;
	double yawAngle = x * 30.0_deg;

	double range = 0.0;
	for ( size_t i = 0; i < c_samplesPerFrame; i++ )
	{
		double theta = m_normal( m_generator );
		double phi = m_uniform( m_generator );

		double xRay = theta * cos( phi );
		double pitchAngle = theta * sin( phi );

		//float y = -1.0 + 2.0 * (float)i / (float)c_rays;
		//double pitchAngle = 2.5_deg * y;

		if ( ! detail || abs( pitchAngle ) <= m_detail )
		{
			if ( scanOneRay( pitchAngle, xRay + yawAngle, range ) )
			{
				//If there is a possible obstacle then record this info.
				setObstacle( range );
			}
		}
	}
}

void Scooter::Radar::scanOneLine(bool detail)
{
	float x = 1.0 - 2.0 * (float)m_xIndex / (float)SIDE_LENGTH;
	double yawAngle = x * 30.0_deg;

	double range = 0.0;
	for ( size_t i = 0; i < c_rays; i++ )
	{
		float y = -1.0 + 2.0 * (float)i / (float)c_rays;
		double pitchAngle = 2.5_deg * y;

		if ( ! detail || abs( pitchAngle ) <= m_detail )
		{
			if ( scanOneRay( pitchAngle, yawAngle, range ) )
			{
				//If there is a possible obstacle then record this info.
				setObstacle( range );
			}
		}
	}
}

bool Scooter::Radar::scanOneRay( double pitchAngle, double yawAngle, double& range )
{
	Vec3 pos = m_aircraftState.getWorldPosition();

	bool obstacle = false;

	double relativePitch;
	if ( m_aoaCompSwitch )
		relativePitch = pitchAngle - m_sweepAngle - m_aircraftState.getAOA() * cos( m_aircraftState.getAngle().x );
	else
		relativePitch = pitchAngle - m_sweepAngle;

	double pitch = relativePitch + m_aircraftState.getAngle().z;

	Vec3 dir = directionVector( pitch, m_aircraftState.getAngle().y + yawAngle );
	Vec3 ground;
	bool found = getIntersection( ground, pos, dir );

	if ( found )
	{
		range = magnitude( ground - pos );
		unsigned char type = getType( ground.x, ground.z );

		Vec3 normal = getNormal( ground.x, ground.z );

		double reflectivity = getReflection( dir, normal, (TerrainType)type );

		/*if ( reflectivity < c_SNR )
			return false;*/
		
		reflectivity *= 1.0e-3 / m_gain;//rangeKM * rangeKM / (1e5 * m_gain);

		double warningAngle = -calculateWarningAngle( range );


		obstacle = warningAngle < relativePitch;


		size_t yIndex;
		size_t yIndexMax;
		if ( rangeToDisplayIndex( range, yIndex ) )
		{
			if ( ! rangeToDisplayIndex( range + c_pulseDistance, yIndexMax ) )
			{
				m_scanIntensity[yIndex] = clamp( m_scanIntensity[yIndex] + reflectivity, 0.0, 1.0 );
				m_scanAngle[yIndex] = std::max( m_scanAngle[yIndex], relativePitch );
			}
			else
			{
				double num = (double)yIndexMax - (double)yIndex;
				double intensity = reflectivity / num;

				for ( size_t i = yIndex; i <= yIndexMax; i++ )
				{
					m_scanIntensity[i] = clamp( m_scanIntensity[i] + reflectivity, 0.0, 1.0 );
					m_scanAngle[i] = std::max( m_scanAngle[i], relativePitch );
				}
			}
		}
	}

	return obstacle;
}

void Scooter::Radar::drawScan()
{
	m_cleared = false;

	for ( size_t i = 0; i < SIDE_LENGTH; i++ )
	{
		size_t index;
		findIndex( m_xIndex, i, index );

		double decay = -m_storage;

		if ( m_xIndex == 0 || m_xIndex == (SIDE_LENGTH - 1) )
			decay *= 2.0;

		m_scope.addBlobOpacity( index, decay );
		//m_scope.setBlobOpacity( index, 0.0 );
	}
		

	for ( size_t i = 0; i < SIDE_LENGTH; i++ )
	{
		if ( m_scanIntensity[i] == 0.0 )
		{
			bool inLimits = i > 0 && i < (SIDE_LENGTH - 1);

			if ( inLimits && m_scanIntensity[i + 1] != 0.0 && m_scanIntensity[i - 1] != 0.0 )
			{
				m_scanIntensity[i] = (m_scanIntensity[i + 1] + m_scanIntensity[i - 1]) / 2.0;
			}
			else
				continue;
		}

		size_t index;
		findIndex( m_xIndex, i, index );
		m_scope.setBlobOpacity( index, m_brilliance * clamp( m_scanIntensity[i], 0.0, 1.0) );
	}
}

void Scooter::Radar::scanAG(double dt)
{
	m_y -= 2.0 * dt;

	//Gone off the bottom reset to the top.
	if ( m_y < -1.0 )
		m_y = 1.0;

	m_locked = false;
	m_range = 0.0;

	//This is similar to the old AG radar cast.
	//The minimum range is taken, this means the CP-741/A must have a fudge factor.
	//This is because the minimum range will most likely be 0.25 degrees below the weapons datum.
	for ( size_t i = 0; i < c_raysAG; i++ )
	{
		float y = -1.0 + 2.0 * (float)i / (float)c_raysAG;

		//Minus 3.0 degress for Aircraft weapons datum.
		double cosRoll = cos( m_aircraftState.getAngle().x );
		double sinRoll = sin( m_aircraftState.getAngle().x );

		Vec3 dir = directionVector( y * 0.25_deg + m_aircraftState.getAngle().z - 3.0_deg * cosRoll, m_aircraftState.getAngle().y - 3.0_deg * sinRoll );
		Vec3 pos = m_aircraftState.getWorldPosition();
		Vec3 ground;

		if ( getIntersection( ground, pos, dir, 15000.0_yard ) )
		{
			Vec3 normal = getNormal( ground.x, ground.z );
			TerrainType type = (TerrainType)getType( ground.x, ground.z );
			double reflection = getReflection( dir, normal, type );

			//Return must be sufficiently strong
			if ( reflection > 0.01 )
			{
				double foundRange = magnitude( ground - pos );

				if ( foundRange < m_range || ! m_locked )
				{
					m_locked = true;
					m_range = foundRange;
				}
			}
		}
	}

	if ( m_locked )
	{
		double displayY = rangeToDisplay( m_range );

		if ( m_converged || abs( displayY - m_y ) < 0.1 )
		{
			m_y = displayY;
			m_converged = true;
		}
	}
	else
		m_converged = false;
}

void Scooter::Radar::drawScanAG()
{
	const size_t spaceWidth = 32;

	for ( size_t i = (spaceWidth / 2); i < (SIDE_LENGTH - (spaceWidth /2)); i++ )
	{
		double x;
		double y;
		indexToScreenCoords( i, x, y );

		m_scope.setBlob( i, x, m_y, 1.0 );
	}
}

void Scooter::Radar::scanProfile( double dt )
{
	updateGimbalProfile( dt );
	resetScanData();
	scanOneLine( true );

	if ( m_obstacle )
		printf( "OBSTACLE\n" );
}

void Scooter::Radar::updateGimbalProfile( double dt )
{
	m_sweepAngle += 5.0 * dt * m_direction;

	if ( m_sweepAngle >= 15.0_deg )
	{
		m_sweepAngle = 15.0_deg;
		m_direction = -1;

		//Every time we hit the edge of the scan decrease the obstacle
		//counter.
		updateObstacleData();
	}
	else if ( m_sweepAngle <= -10.0_deg )
	{
		m_sweepAngle = -10.0_deg;
		m_direction = 1;

		//Every time we hit the edge of the scan decrease the obstacle
		//counter.
		updateObstacleData();
	}
}

void Scooter::Radar::drawScanProfile()
{
	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		m_scope.addBlobOpacity( i, -m_storage );
		double x;
		double y;
		indexToScreenCoords( i, x, y );
		m_scope.setBlobPos( i, x + (random() - 0.5) * 0.04, y + (random() - 0.5) * 0.04 );
	}

	bool obstacle = false;
	
	for ( size_t i = 0; i < SIDE_LENGTH; i++ )
	{
		if ( m_scanIntensity[i] == 0.0 )
			continue;


		double normalisedAngle = (15.0_deg / 25.0_deg) + (m_scanAngle[i] / 25.0_deg); //clamp((10.0_deg - m_scanProfile[i]) / 25.0_deg, 0.0, 1.0);

		size_t index;
		if ( findIndex( i, round(normalisedAngle * (double)SIDE_LENGTH), index ) )
			m_scope.setBlobOpacity( index, m_brilliance * clamp( m_scanIntensity[i], 0.0, 1.0 ) );
	}

	m_cleared = false;
}

void Scooter::Radar::resetLineDraw()
{
	for ( size_t i = 0; i < SIDE_LENGTH; i++ )
	{
		double x;
		double y;

		indexToScreenCoords( i, x, y );
		m_scope.setBlobPos( i, x, y );
	}
}

void Scooter::Radar::clearScan()
{
	if ( m_cleared )
		return;

	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		m_scope.setBlobOpacity( i, 0.0 );
	}

	m_cleared = true;
}


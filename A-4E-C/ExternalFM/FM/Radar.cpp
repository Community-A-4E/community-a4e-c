#include "Radar.h"
#include <Common/Maths.h>
#include <math.h>
#include "ShipFinder.h"
#include "AirframeConstants.h"

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

constexpr static double c_knobStep = 0.04;

constexpr static double c_knobSpeed = 0.5;

static double f( double x )
{
	return exp( -0.5 * pow( x / c_beamSigma, 2.0 ) );
}

static double fNorm( double x )
{
	return ( 1.0 / ( c_beamSigma * sqrt( 2.0 * PI ) ) ) * f(x);
}

Scooter::Radar::Radar( Interface& inter, AircraftState& state ) :
	m_scope( inter ),
	m_aircraftState( state ),
	m_interface( inter ),
	m_normal( 0.0, c_beamSigma ),
	m_uniform( 0.0, 2.0 * PI ),
	m_generator( 23 )
{
	//for ( size_t i = 0; i < SIDE_LENGTH; i++ )
		//m_scanLine[i] = Vec3f();

	resetDraw();

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

	m_radarTilting = 0;
	m_volumeMoving = 0;
	m_brillianceMoving = 0;
	m_storageMoving = 0;
	m_gainMoving = 0;
	m_detailMoving = 0;

	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_GAIN, 0.50f );
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_BRILLIANCE, 1.0f );
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_DETAIL, 1.0f );
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_STORAGE, 0.94f );
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_ANGLE, 0.4f );

}

void Scooter::Radar::coldInit()
{
	zeroInit();
}

void Scooter::Radar::hotInit()
{
	zeroInit();

	if ( m_disabled )
		return;

	m_warmup = m_warmupTime;
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, 0.1f );
}

void Scooter::Radar::airborneInit()
{
	zeroInit();

	if ( m_disabled )
		return;

	m_warmup = m_warmupTime;
	ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, 0.1f );
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
		angle( value );
		return true;
	case DEVICE_COMMANDS_RADAR_AOACOMP:
		m_aoaCompSwitch = (bool)value;
		return true;
	case DEVICE_COMMANDS_RADAR_MODE:
		m_modeSwitch = State(round(value * 10.0));
		return true;
	case DEVICE_COMMANDS_RADAR_FILTER:
		m_scope.setFilter( ! (bool)value );
		return true;
	case DEVICE_COMMANDS_RADAR_DETAIL:
		detail( value );
		return true;
	case DEVICE_COMMANDS_RADAR_DETAIL_AXIS_ABS:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_DETAIL, angleAxisToCommand(value));
		return true;
	case DEVICE_COMMANDS_RADAR_GAIN:
		gain( value );
		return true;
	case DEVICE_COMMANDS_RADAR_GAIN_AXIS_ABS:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_GAIN, angleAxisToCommand(value));
		return true;
	case DEVICE_COMMANDS_RADAR_BRILLIANCE:
		m_brilliance = value;
		return true;
	case DEVICE_COMMANDS_RADAR_BRILLIANCE_AXIS_ABS:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_BRILLIANCE, angleAxisToCommand(value));
		return true;
	case DEVICE_COMMANDS_RADAR_STORAGE:
		storage( value );
		return true;
	case DEVICE_COMMANDS_RADAR_STORAGE_AXIS_ABS:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_STORAGE, angleAxisToCommand(value));
		return true;
	case DEVICE_COMMANDS_RADAR_PLANPROFILE:
		//This should perhaps be a state change.
		m_planSwitch = (bool)value;
		return true;
	case DEVICE_COMMANDS_RADAR_VOLUME:
		m_obstacleVolume = value;
		return true;
	case DEVICE_COMMANDS_RADAR_RETICLE:
		m_reticleKnob = value;
		return true;
	case DEVICE_COMMANDS_RADAR_RETICLE_AXIS_ABS:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_RETICLE, angleAxisToCommand(value));
		return true;
	case DEVICE_COMMANDS_RADAR_ANGLE_AXIS:
		m_radarAngleAxis = value;
		return true;
	case DEVICE_COMMANDS_RADAR_ANGLE_AXIS_ABS:
		m_angleKnob = value;
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_ANGLE, angleAxisToCommand(value));
		return true;
	case KEYS_RADARMODE:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, (float)( ( m_modeSwitch + 1 ) % MODE_NUM ) / 10.0f );
		return true;
	case KEYS_RADARMODECW:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, std::min( (float)( m_modeSwitch + 1 ), (float)MODE_AG ) / 10.0f );
		return true;
	case KEYS_RADARMODECCW:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, std::max((float)( m_modeSwitch - 1 ), 0.0f) / 10.0f );
		return true;
	case KEYS_RADARMODEOFF:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, (float)MODE_OFF / 10.0f );
		return true;
	case KEYS_RADARMODESTBY:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, (float)MODE_STBY / 10.0f );
		return true;
	case KEYS_RADARMODESEARCH:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, (float)MODE_SRCH / 10.0f );
		return true;
	case KEYS_RADARMODETC:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, (float)MODE_TC / 10.0f );
		return true;
	case KEYS_RADARMODEA2G:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_MODE, (float)MODE_AG / 10.0f );
		return true;
	case KEYS_RADARTCPLANPROFILE:
		printf( "value: %lf, current: %d\n", value, m_planSwitch );
		if ( value == -1.0 )
			ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_PLANPROFILE, !m_planSwitch );
		else
			ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_PLANPROFILE, value );
		return true;
	case KEYS_RADARRANGELONGSHORT:
		if ( value == -1.0 )
			ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_RANGE, !m_rangeSwitch );
		else
			ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_RANGE, value );
		return true;
	case KEYS_RADARAOACOMP:
		if ( value == -1.0 )
			ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_AOACOMP, !m_aoaCompSwitch );
		else
			ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_AOACOMP, value );
		return true;
	case KEYS_RADARVOLUME:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_VOLUME, float(clamp(m_obstacleVolume + (value == 1.0 ? 0.1 : -0.1), 0.0, 1.0)) );
		return true;
	case KEYS_RADARTILTINC:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_ANGLE, float(clamp(0.04 + m_angleKnob, 0.0, 1.0) ));
		return true;
	case KEYS_RADARTILTDEC:
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, DEVICE_COMMANDS_RADAR_ANGLE, float(clamp(-0.04 + m_angleKnob, 0.0, 1.0)) );
		return true;
	case KEYS_RADARTILTSTARTUP:
		m_radarTilting = 1;
		return true;
	case KEYS_RADARTILTSTARTDOWN:
		m_radarTilting = -1;
		return true;
	case KEYS_RADARTILTSTOP:
		m_radarTilting = 0;
		return true;
	case KEYS_RADARVOLUMESTARTUP:
		m_volumeMoving = 1;
		return true;
	case KEYS_RADARVOLUMESTARTDOWN:
		m_volumeMoving = -1;
		return true;
	case KEYS_RADARVOLUMESTOP:
		m_volumeMoving = 0;
		return true;
	case KEYS_RADAR_BRIL_STEP_INC:
		setKnob( DEVICE_COMMANDS_RADAR_BRILLIANCE, m_brilliance + c_knobStep );
	case KEYS_RADAR_BRIL_STEP_DEC:
		setKnob( DEVICE_COMMANDS_RADAR_BRILLIANCE, m_brilliance - c_knobStep );
		return true;
	case KEYS_RADAR_BRIL_CONT_UP:
		m_brillianceMoving = 1;
		return true;
	case KEYS_RADAR_BRIL_CONT_DOWN:
		m_brillianceMoving = -1;
		return true;
	case KEYS_RADAR_BRIL_CONT_STOP:
		m_brillianceMoving = 0;
		return true;
	case KEYS_RADAR_STOR_STEP_INC:
		setKnob( DEVICE_COMMANDS_RADAR_STORAGE, m_storageKnob + c_knobStep );
		return true;
	case KEYS_RADAR_STOR_STEP_DEC:
		setKnob( DEVICE_COMMANDS_RADAR_STORAGE, m_storageKnob - c_knobStep );
		return true;
	case KEYS_RADAR_STOR_CONT_UP:
		m_storageMoving = 1.0f;
		return true;
	case KEYS_RADAR_STOR_CONT_DOWN:
		m_storageMoving = -1.0f;
		return true;
	case KEYS_RADAR_STOR_CONT_STOP:
		m_storageMoving = 0.0f;
		return true;
	case KEYS_RADAR_GAIN_STEP_INC:
		setKnob( DEVICE_COMMANDS_RADAR_GAIN, m_gainKnob + c_knobStep );
		return true;
	case KEYS_RADAR_GAIN_STEP_DEC:
		setKnob( DEVICE_COMMANDS_RADAR_GAIN, m_gainKnob - c_knobStep );
		return true;
	case KEYS_RADAR_GAIN_CONT_UP:
		m_gainMoving = 1.0f;
		return true;
	case KEYS_RADAR_GAIN_CONT_DOWN:
		m_gainMoving = -1.0f;
		return true;
	case KEYS_RADAR_GAIN_CONT_STOP:
		m_gainMoving = 0.0f;
		return true;
	case KEYS_RADAR_DET_STEP_INC:
		setKnob( DEVICE_COMMANDS_RADAR_DETAIL, m_detailKnob + c_knobStep );
		return true;
	case KEYS_RADAR_DET_STEP_DEC:
		setKnob( DEVICE_COMMANDS_RADAR_DETAIL, m_detailKnob - c_knobStep );
		return true;
	case KEYS_RADAR_DET_CONT_UP:
		m_detailMoving = 1.0f;
		return true;
	case KEYS_RADAR_DET_CONT_DOWN:
		m_detailMoving = -1.0f;
		return true;
	case KEYS_RADAR_DET_CONT_STOP:
		m_detailMoving = 0.0f;
		return true;
	case KEYS_RADAR_RET_STEP_INC:
		setKnob( DEVICE_COMMANDS_RADAR_RETICLE, m_reticleKnob + c_knobStep );
		return true;
	case KEYS_RADAR_RET_STEP_DEC:
		setKnob( DEVICE_COMMANDS_RADAR_RETICLE, m_reticleKnob - c_knobStep );
		return true;
	case KEYS_RADAR_RET_CONT_UP:
		m_reticleMoving = 1.0f;
		return true;
	case KEYS_RADAR_RET_CONT_DOWN:
		m_reticleMoving = -1.0f;
		return true;
	case KEYS_RADAR_RET_CONT_STOP:
		m_reticleMoving = 0.0f;
		return true;
	case DEVICE_COMMANDS_RADAR_STORAGE_AXIS_SLEW:
		m_storageMoving = value;
		return true;
	case DEVICE_COMMANDS_RADAR_BRILLIANCE_AXIS_SLEW:
		m_brillianceMoving = value;
		return true;
	case DEVICE_COMMANDS_RADAR_GAIN_AXIS_SLEW:
		m_gainMoving = value;
		return true;
	case DEVICE_COMMANDS_RADAR_DETAIL_AXIS_SLEW:
		m_detailMoving = value;
		return true;
	case DEVICE_COMMANDS_RADAR_RETICLE_AXIS_SLEW:
		m_reticleMoving = value;
		return true;
	}

	return false;
}

void Scooter::Radar::resetDraw()
{
	double dy = (0.4 / (double)SIDE_HEIGHT);

	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		double x;
		double y;

		indexToScreenCoords( i, x, y );
		m_scope.setBlobPos( i, x, y + dy * randomCentred() );
	}
}

void Scooter::Radar::update( double dt )
{

	if ( m_disabled )
	{
		return;
	}

	if ( ! m_self_test_ran )
		RadarHackSelfTest();

	moveKnob( DEVICE_COMMANDS_RADAR_VOLUME,			m_obstacleVolume,	dt * c_knobSpeed, m_volumeMoving );
	moveKnob( DEVICE_COMMANDS_RADAR_ANGLE,			m_angleKnob,		dt * c_knobSpeed, m_radarTilting );
	moveKnob( DEVICE_COMMANDS_RADAR_BRILLIANCE,		m_brilliance,		dt * c_knobSpeed, m_brillianceMoving );
	moveKnob( DEVICE_COMMANDS_RADAR_DETAIL,			m_detailKnob,		dt * c_knobSpeed, m_detailMoving );
	moveKnob( DEVICE_COMMANDS_RADAR_GAIN,			m_gainKnob,			dt * c_knobSpeed, m_gainMoving );
	moveKnob( DEVICE_COMMANDS_RADAR_STORAGE,		m_storageKnob,		dt * c_knobSpeed, m_storageMoving );
	moveKnob( DEVICE_COMMANDS_RADAR_RETICLE,		m_reticleKnob,		dt * c_knobSpeed, m_reticleMoving );

	moveKnob( DEVICE_COMMANDS_RADAR_ANGLE, m_angleKnob, dt * c_knobSpeed, m_radarAngleAxis );


	if ( m_interface.getElecMonitoredAC() )
	{
		m_scope.setReticle( m_reticleKnob / 2.0 );
	}
	else
	{
		m_scope.setReticle( 0.0 );
	}

	State newState = getState();
	
	if ( newState != m_state )
	{
		transitionState( m_state, newState );
		m_state = newState;
	}

	double warmupAmount = dt;

	switch ( m_state )
	{
	case STATE_OFF:
		warmupAmount = -0.5 * dt;
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
		scanAG2( dt );
		drawScanAG();
		break;
	}

	warmup( warmupAmount );

	if ( receiver_damage->GetDamage() > 0.1 )
	{
		m_warmup = 0.0;
	}
	

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
	for ( size_t i = 0; i < SIDE_HEIGHT; i++ )
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
	float x = 1.0f - 2.0f * float(m_xIndex) / float(SIDE_LENGTH);
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
			if ( scanOneRay( false, pitchAngle, xRay + yawAngle, range ) )
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
	float x = 1.0f - 2.0f * float(m_xIndex) / float(SIDE_LENGTH);
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
			if ( scanOneRay( false, pitchAngle, xRay + yawAngle, range ) )
			{
				//If there is a possible obstacle then record this info.
				setObstacle( range );
			}
		}
	}

	findShips( yawAngle, detail );
}

void Scooter::Radar::scanOneLine(bool detail)
{
	float x = 1.0f - 2.0f * float(m_xIndex) / float(SIDE_LENGTH);
	double yawAngle = x * 30.0_deg;

	double range = 0.0;
	for ( size_t i = 0; i < c_rays; i++ )
	{
		float y = -1.0f + 2.0f * float(i) / float(c_rays);
		double pitchAngle = 2.5_deg * y;

		if ( ! detail || abs( pitchAngle ) <= m_detail )
		{
			if ( scanOneRay( false, pitchAngle, yawAngle, range ) )
			{
				//If there is a possible obstacle then record this info.
				setObstacle( range );
			}
		}
	}
}

void Scooter::Radar::findShips( double yawAngle, bool detail )
{
	const std::vector<Ship>* shipsPtr = getShips();

	if ( ! shipsPtr )
		return;

	const std::vector<Ship>& ships = *shipsPtr;

	double relativePitch;
	if ( m_aoaCompSwitch )
		relativePitch = m_aircraftState.getAngle().z - m_sweepAngle - m_aircraftState.getAOA() * cos( m_aircraftState.getAngle().x );
	else
		relativePitch = m_aircraftState.getAngle().z - m_sweepAngle;

	Vec3 beamDirection = directionVector( relativePitch, m_aircraftState.getAngle().y + yawAngle );
	
	for ( size_t i = 0; i < ships.size(); i++ )
	{
		Vec3 r = ships[i].pos - m_aircraftState.getWorldPosition();
		double dot = normalize(r) * beamDirection;
		double angle = acos( dot );
		if ( angle < 2.5_deg )
		{
			double range = getCorrectedRange(magnitude( r ));
			double elevation = asin( r.y / range );
			//printf( "Range: %lf, Elevation %lf, Azimith\n", range, elevation );
			size_t index;
			if ( rangeToDisplayIndex( range, index ) && ( ! detail || abs(elevation) <= m_detail ) ) 
			{
				double headingDiff = toRad(ships[i].heading + 45.0) - m_aircraftState.getAngle().y;
				double gain = f( angle ) * getShipGain( ships[i].rcs, range ) * ( abs(sin( headingDiff )) + 0.1 ) * getWarmupFactor();
				m_scanIntensity[index] += gain;
			}
		}
	}
}

bool Scooter::Radar::scanOneRay( bool boresight, double pitchAngle, double yawAngle, double& range, double& reflectivityOut )
{
	Vec3 pos = m_aircraftState.getWorldPosition();

	bool obstacle = false;
	
	double relativePitch;

	if ( boresight )
		relativePitch = pitchAngle;
	else if ( m_aoaCompSwitch )
		relativePitch = pitchAngle - m_sweepAngle - m_aircraftState.getAOA() * cos( m_aircraftState.getAngle().x );
	else
		relativePitch = pitchAngle - m_sweepAngle;

	double pitch = relativePitch + m_aircraftState.getAngle().z;

	Vec3 dir = directionVector( pitch, m_aircraftState.getAngle().y + yawAngle );
	Vec3 ground;
	bool found = getIntersection( ground, pos, dir );

	if ( found )
	{
		range = getCorrectedRange( magnitude( ground - pos ) );
		unsigned char type = getType( ground.x, ground.z );

		Vec3 normal = getNormal( ground.x, ground.z );

		double reflectivity = getReflection( dir, normal, (TerrainType)type ) * getWarmupFactor();
		reflectivityOut = reflectivity;
		
		reflectivity *= 2.0e-4 / m_gain;//rangeKM * rangeKM / (1e5 * m_gain);

		double warningAngle = -calculateWarningAngle( range );


		obstacle = warningAngle < relativePitch;


		size_t yIndex;
		size_t yIndexMax;
		if ( rangeToDisplayIndex( range, yIndex ) )
		{
			if ( rangeToDisplayIndex( range + c_pulseDistance, yIndexMax ) && yIndexMax > yIndex )
			{
				double num = (double)yIndexMax - (double)yIndex;
				double intensity = reflectivity / num;

				for ( size_t i = yIndex; i <= yIndexMax; i++ )
				{
					m_scanIntensity[i] += intensity; //clamp( m_scanIntensity[i] + intensity, 0.0, 1.0 );
					m_scanAngle[i] = std::max( m_scanAngle[i], relativePitch );
				}
			}
			else
			{
				m_scanIntensity[yIndex] += reflectivity; //clamp( m_scanIntensity[yIndex] + reflectivity, 0.0, 1.0 );
				m_scanAngle[yIndex] = std::max( m_scanAngle[yIndex], relativePitch );
			}
		}
	}

	return obstacle;
}

void Scooter::Radar::drawScan()
{
	m_scope.addToDisplay( -m_storage );

	//for ( size_t i = 0; i < SIDE_LENGTH; i++ )
	//{
	//	size_t index;
	//	findIndex( m_xIndex, i, index );

	//	double decay = -m_storage;

	//	if ( m_xIndex == 0 || m_xIndex == (SIDE_LENGTH - 1) )
	//		decay *= 2.0;

	//	m_scope.addBlobOpacity( index, decay );
	//	//m_scope.setBlobOpacity( index, 0.0 );
	//}
		

	for ( size_t i = 0; i < SIDE_HEIGHT; i++ )
	{
		if ( m_scanIntensity[i] == 0.0 )
		{
			bool inLimits = i > 0 && i < (SIDE_HEIGHT - 1);

			if ( inLimits && m_scanIntensity[i + 1] != 0.0 && m_scanIntensity[i - 1] != 0.0 )
			{
				m_scanIntensity[i] = (m_scanIntensity[i + 1] + m_scanIntensity[i - 1]) / 2.0;
			}
			else
				continue;
		}

		size_t index;
		findIndex( m_xIndex, i, index );

		
		m_scope.addBlobOpacity(index, m_scanIntensity[i], m_brilliance);

	}
}

struct Range
{
	double r;
	double I;
};

void Scooter::Radar::scanAG2( double dt )
{
	static Range s_rangeData[c_samplesPerFrame];

	m_y -= 2.0 * dt;

	//Gone off the bottom reset to the top.
	if ( m_y < -1.0 )
		m_y = 1.0;

	m_locked = false;
	m_range = 0.0;


	
	double rangeAverage = 0.0;

	size_t count = 0;
	for ( size_t i = 0; i < c_samplesPerFrame; i++ )
	{
		double theta = m_normal( m_generator );
		double phi = m_uniform( m_generator );

		double xRay = theta * cos( phi );
		double pitchAngle = theta * sin( phi );
		double reflectivity;
		double range = 0.0;
		scanOneRay( true, pitchAngle + c_weaponsDatum, xRay, range, reflectivity );
		if ( range > 0.0 )
		{
			double rangeKm = range / 1000.0;
			double returnStrength = clamp(reflectivity / pow( rangeKm, 2.0 ), 0.0, 1.0); //maybe clamp?
			s_rangeData[count].I = returnStrength;
			s_rangeData[count].r = range;
			count++;
		}
	}

	double intensity = 0.0;
	for ( size_t i = 0; i < count; i++ )
	{
		intensity += s_rangeData[i].I;
	}

	for ( size_t i = 0; i < count; i++ )
	{
		rangeAverage += s_rangeData[i].r * s_rangeData[i].I / intensity;
	}

	m_locked = intensity > 0.5;
	m_range = m_locked ? rangeAverage : 0.0;

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
	for ( size_t i = 0; i < 1; i++ )
	{
		float y = -1.0f + 2.0f * float(i) / float(c_raysAG);

		//Minus 3.0 degress for Aircraft weapons datum.
		double cosRoll = cos( m_aircraftState.getAngle().x );
		double sinRoll = sin( m_aircraftState.getAngle().x );

		Vec3 dir = directionVector( /*y * 0.25_deg +*/ m_aircraftState.getAngle().z - 3.0_deg * cosRoll, m_aircraftState.getAngle().y - 3.0_deg * sinRoll );
		Vec3 pos = m_aircraftState.getWorldPosition();
		Vec3 ground;

		if ( getIntersection( ground, pos, dir, 15000.0_yard ) )
		{
			Vec3 normal = getNormal( ground.x, ground.z );
			TerrainType type = (TerrainType)getType( ground.x, ground.z );
			double reflection = getReflection( dir, normal, type ) * getWarmupFactor();

			//Return must be sufficiently strong
			if ( reflection > 0.01 )
			{
				double foundRange = getCorrectedRange( magnitude( ground - pos ) );

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
		m_scope.addBlobOpacity( i, -m_storage, m_brilliance );
		double x;
		double y;
		indexToScreenCoords( i, x, y );
		m_scope.setBlobPos( i, x + (random() - 0.5) * 0.04, y + (random() - 0.5) * 0.04 );
	}

	bool obstacle = false;
	
	for ( size_t i = 0; i < SIDE_HEIGHT; i++ )
	{
		if ( m_scanIntensity[i] == 0.0 )
			continue;


		double normalisedAngle = (15.0_deg / 25.0_deg) + (m_scanAngle[i] / 25.0_deg); //clamp((10.0_deg - m_scanProfile[i]) / 25.0_deg, 0.0, 1.0);

		size_t index;
		const size_t horizontal_scan_index = size_t( double( i ) * SIDE_RATIO );
		const size_t vertical_scan_index = size_t( round( normalisedAngle * double( SIDE_HEIGHT ) ) );
		if ( findIndex( horizontal_scan_index, vertical_scan_index, index ) )
			m_scope.addBlobOpacity( index, m_scanIntensity[i], m_brilliance );
	}
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
	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		m_scope.setBlobOpacity( i, 0.0 );
	}
}

// Check there aren't any crashes introduced by an update.
void Scooter::Radar::RadarHackSelfTest()
{
	printf( " ========== Begin Radar Self Test ==========\n" );

	Vec3 out;
	const Vec3& pos = m_aircraftState.getWorldPosition();
	bool intersects = getIntersection( out, pos, Vec3( 0.0, -1.0, 0.0 ), 100'000.0 );
	printf( "[getIntersection] %d, (%lf,%lf,%lf)\n", intersects, out.x, out.y, out.z );

	Vec3 normal = getNormal( pos.x, pos.z );
	printf( "[getNormal] %lf,%lf,%lf\n", normal.x, normal.y, normal.z );
	printf( "[getType] %u\n", (unsigned int)getType( pos.x, pos.z ) );

	printf( " ========== End Radar Self Test ==========\n" );
	m_self_test_ran = true;
}



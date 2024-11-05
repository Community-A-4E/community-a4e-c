#pragma once
#include <random>
#include <Common/Devices.h>
#include "Commands.h"
#include "RadarScope.h"
#include "AircraftState.h"
#include "Units.h"
#include <Common/Maths.h>
#include "BaseComponent.h"
#include "cockpit_base_api.h"
#include <Common/Ship.h>
#include "Damage.h"

constexpr static double c_obstructionPeriod = 2.0;

inline void* find_vfptr( void* ptr, int offset )
{
	return ( *(void***)ptr )[offset];
}

inline void* find_vfptr_raw( void* ptr, int offset )
{
	return find_vfptr( ptr, offset / 8 );
}

typedef bool (*FNC_INTERSECTION)(void* object, Vec3f* point, Vec3f* direction, float maxDist, Vec3f* out);
typedef unsigned char (*FNC_TYPE)(void* object, float x, float z);
typedef void (*FNC_GET_NORMAL)(void* object, Vec3f* n, float x, float z);

namespace Scooter
{

class Radar : public BaseComponent
{
public:
	Radar( Interface& inter, AircraftState& state );

	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();
	
	bool handleInput( int command, float value );
	void update(double dt);
	inline void setDisable( bool disabled );
	inline double getRange();

	enum TerrainType
	{
		LAND = 0,
		SEA = 1,
		SHORE = 3,
		ROAD = 2,
		RIVER = 4,
		CITY = 5,
		LAKE = 7,
		RAILWAY = 9,
		FOREST = 49,
		FARMLAND = 22,
		AIRFIELD = 23,
	};

private:

	

	enum State
	{
		STATE_OFF,
		STATE_STBY,
		STATE_SRCH,
		STATE_TC_PROFILE,
		STATE_TC_PLAN,
		STATE_AG,
	};

	enum Mode
	{
		MODE_OFF,
		MODE_STBY,
		MODE_SRCH,
		MODE_TC,
		MODE_AG,
		MODE_NUM,
	};


	inline double rangeToDisplay( double range );
	inline bool rangeToDisplayIndex( double range, size_t& index );
	
	inline State getState();
	inline void warmup( double rate );
	inline void transitionState( State from, State to );

	// Hack functions
	inline unsigned char getType( double x, double z );
	inline bool getIntersection( Vec3& out, const Vec3& pos, const Vec3& dir, double maxRange = 0.0 );
	inline Vec3 getNormal(double x, double z);

	inline double calculateWarningAngle( double range );
	inline void updateObstacleData();
	inline void resetObstacleData();
	inline void setObstacle(double range);
	inline void updateObstacleLight( double dt );
	
	static inline bool coordToIndex( double coord, size_t& index );
	static inline bool findIndex( size_t horizontalScanIndex, size_t verticalScanIndex, size_t& index );
	static inline void indexToScreenCoords( size_t index, double& x, double& y );
	static inline bool screenCoordToIndex( double x, double y, size_t& index );
	static inline double getReflection( const Vec3& dir, const Vec3& normal, TerrainType type );
	static inline double typeReflectivity( TerrainType type );
	static inline float angleAxisToCommand( double axis );
	static inline double getShipGain( double rcs, double range );

	inline double getCorrectedRange( double range )
	{
		double warmupFactor = getWarmupFactor();
		return clamp(warmupFactor * range, 0.0, double(40.0_nauticalMile));
	}
	
	inline double getWarmupFactor();

	void scanPlan(double dt);
	void updateWarmup(double dt);
	void updateGimbalPlan();
	void updateGimbalProfile(double dt);
	void resetScanData();
	void scanOneLine(bool detail);
	void scanOneLine2( bool detail );
	void scanOneLine3( bool detail );
	bool scanOneRay(bool boresight, double pitchAngle, double yawAngle, double& range) 
	{
		double reflection;
		return scanOneRay(boresight, pitchAngle, yawAngle, range, reflection );
	}
	bool scanOneRay( bool boresight, double pitchAngle, double yawAngle,  double& range, double& reflection );
	void findShips( double yawAngle, bool detail );

	void drawScan();
	void scanAG(double dt);
	void scanAG2( double dt );
	void scanProfile( double dt );
	void drawScanAG();
	void drawScanProfile();
	void clearScan();
	void resetLineDraw();
	void resetDraw();

	void RadarHackSelfTest();
	bool m_self_test_ran = false;

	RadarScope m_scope;
	AircraftState& m_aircraftState;
	Interface& m_interface;

	void* m_terrain = nullptr;

	double m_scale = 1.0;

	int m_xIndex = 25;
	int m_yIndex = 0;
	double m_y = 0.0;
	int m_direction = -1;
	int m_scanned = 0;
	bool m_disabled = true;


	int m_radarTilting = 0;
	int m_volumeMoving = 0;


	float m_brillianceMoving = 0.0f;
	float m_storageMoving = 0.0f;
	float m_gainMoving = 0.0f;
	float m_detailMoving = 0.0f;
	float m_reticleMoving = 0.0f;

	double m_radarAngleAxis = 0.0;


	//Intensity of return and Pitch Angle against range index.
	double m_scanIntensity[SIDE_HEIGHT];
	double m_scanAngle[SIDE_HEIGHT];

	//Constants
	const double m_warmupTime = 180.0;
	const double m_angularResolution = 1.0_deg;

	//Internal States
	double m_warmup = 0.0;
	double m_scanHeight = 2.5_deg;
	bool m_locked = false;
	bool m_converged = false;
	double m_range = 0.0;
	double m_sweepAngle = 0.0;
	State m_state = STATE_OFF;

	//Obstacle related stuff
	bool m_obstacleIndicator = false;
	double m_obstacleTimer = 0.0;
	double m_minObsRange = 0.0;
	int m_obstacleCount = 0;
	bool m_obstacle = false;
	double m_obstacleVolume = 1.0;

	//Switches
	State m_modeSwitch = STATE_OFF;
	bool m_rangeSwitch = false;
	bool m_aoaCompSwitch = false;

	double m_angle = 0.0;
	double m_detail = 1.0;
	double m_gain = 1.0;
	double m_brilliance = 1.0;
	double m_storage = 1.0;
	bool m_planSwitch = false; // actually plan/profile true when in profile

	double m_storageKnob = 0.0;
	double m_gainKnob = 0.0;
	double m_angleKnob = 0.0;
	double m_detailKnob = 0.0;
	double m_reticleKnob = 0.0;

	std::shared_ptr<DamageObject> receiver_damage = DamageProcessor::MakeDamageObjectMultiple( "Radar Receiver", 
		{ DamageCell::NOSE_CENTER,
			DamageCell::NOSE_BOTTOM,
			DamageCell::NOSE_RIGHT_SIDE,
			DamageCell::NOSE_LEFT_SIDE
		} );

	inline void storage( double value )
	{
		m_storageKnob = value;
		m_storage = ( 0.25 - 0.02 ) * ( 1.0 - value ) + 0.02;
	}
	inline void gain( double value ) 
	{ 
		m_gainKnob = value;
		m_gain = exp( -9 * value );
	}
	inline void detail( double value )
	{ 
		m_detailKnob = value;
		m_detail = ( 1.0 - value ) * ( 2.5_deg - 0.25_deg ) + 0.25_deg;
	}
	inline void angle( double value ) 
	{ 
		m_angleKnob = value;
		m_angle = -10.0_deg + 25.0_deg * value;
	}

	inline void setKnob( Command command, double value, double min = 0.0, double max = 1.0 )
	{
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, command, float(clamp( value, min, max )) );
	}

	inline void moveKnob( Command command, double current, double change, double direction, double min = 0.0, double max = 1.0 )
	{
		if ( direction == 0.0 )
			return;
		ed_cockpit_dispatch_action_to_device( DEVICES_RADAR, command, float(clamp( current + change * direction, min, max )) );
	}

	// Monte Carlo Stuff
	std::default_random_engine m_generator;
	std::normal_distribution<double> m_normal;
	std::uniform_real_distribution<double> m_uniform;
};

double Radar::getWarmupFactor()
{
	if ( m_warmup >= m_warmupTime )
		return 1.0;

	double warmupAmount = 1.0 - ( m_warmup / m_warmupTime );

	return 1.0 + ( 2.0 * random() - 1.0 ) * warmupAmount;
}


double Radar::rangeToDisplay( double range )
{
	return -1.0 + 2.0 * range / (20.0_nauticalMile * m_scale);
}

bool Radar::rangeToDisplayIndex( double range, size_t& index )
{
	index = size_t(round( SIDE_HEIGHT * range / (20.0_nauticalMile * m_scale)));

	if ( index >= 0 && index < SIDE_HEIGHT )
		return true;
	else
		return false;
}


void Radar::transitionState( State from, State to )
{
	resetDraw();

	switch ( from )
	{
	case STATE_AG:
		clearScan();
		break;
	case STATE_TC_PROFILE:
		m_scope.setProfileScribe( RadarScope::OFF );
		clearScan();
		break;
	}

	switch ( to )
	{
	case STATE_AG:
		resetLineDraw();
		clearScan();
		break;
	case STATE_TC_PROFILE:
		clearScan();
		break;
	}
}

double Radar::getReflection( const Vec3& dir, const Vec3& normal, TerrainType type )
{
	return typeReflectivity( type )* normalize( -dir )* normalize( normal );
}

double Radar::typeReflectivity( TerrainType type )
{
	switch ( type )
	{
	case LAND:
		return 1.0;
	case ROAD:
		return 0.7;
	case SHORE:
		return 0.8;
	case SEA:
		return 0.001;
	case RIVER:
		return 0.0001;
	case LAKE:
		return 0.0001;
	case RAILWAY:
		return 50.0;
	case FOREST:
		return 2.0;// + random() * 0.1;
	case CITY:
		return 0.8 + ( random() < 0.7 ? 100.0 : 0.0 );// + random() * 0.5;
	case FARMLAND:
		return 1.2;
	case AIRFIELD:
		return 0.7;
	}

	printf( "%d\n", type );
	return 1.0;
}

void Radar::setDisable( bool disabled )
{
	m_disabled = disabled;
}

void Radar::warmup( double rate )
{
	m_warmup += rate;
	m_warmup = clamp( m_warmup, 0.0, m_warmupTime );
}

void Radar::indexToScreenCoords( size_t index, double& x, double& y )
{
	size_t xI = index % SIDE_LENGTH;
	size_t yI = index / SIDE_LENGTH;

	x = ((double)xI / (double)SIDE_LENGTH) * 2.0 - 1.0;
	y = ((double)yI / (double)SIDE_HEIGHT) * 2.0 - 1.0;
}

bool Radar::screenCoordToIndex( double x, double y, size_t& index )
{
	size_t xI = size_t(round(((x + 1.0) / 2.0) * SIDE_LENGTH));
	size_t yI = size_t(round(((y + 1.0) / 2.0) * SIDE_HEIGHT));

	return findIndex( xI, yI, index);
}

bool Radar::findIndex( size_t horizontalScanIndex, size_t verticalScanIndex, size_t& index )
{
	index = horizontalScanIndex + verticalScanIndex * SIDE_LENGTH;

	if ( index >= 0 && index < MAX_BLOBS )
		return true;
	else
		return false;
}

float Radar::angleAxisToCommand( double axis )
{
	double fraction = abs( axis );

	//0.4 is the centre point.
	//Since it is 25.0_deg * value - 10.0_deg
	//If axis is greater than zero it scales linearly over the remaining upper 0.6 range.
	//If axis is less than zero it scales linearly over the remaining lower 0.4 range.
	return float(axis > 0.0 ? 0.4 + 0.6 * axis : 0.4 + 0.4 * axis);


}

double Radar::getShipGain( double rcs, double range )
{
	range /= 1000.0;
	return c_radarGain * rcs / pow( range, 4 );
}

void Radar::resetObstacleData()
{
	m_minObsRange = 1.0e6;
	m_obstacleCount = 0;
}

void Radar::updateObstacleData()
{
	m_obstacleCount--;

	if ( m_obstacleCount < 0 )
		resetObstacleData();
}

void Radar::setObstacle(double range)
{
	//m_obstacle = true;

	m_obstacleCount = 2;

	if ( range < m_minObsRange )
		m_minObsRange = range;
}

unsigned char Radar::getType( double x, double z )
{
	FNC_TYPE getType = (FNC_TYPE)find_vfptr_raw( m_terrain, 0x50 );
	return getType( m_terrain, (float)x, (float)z );
}


bool Radar::getIntersection( Vec3& out, const Vec3& pos, const Vec3& dir, double maxRange )
{
	if ( maxRange == 0.0 )
		maxRange = 20.0_nauticalMile * m_scale;

	FNC_INTERSECTION getIntersection = (FNC_INTERSECTION)find_vfptr_raw( m_terrain, 0x68 );

	Vec3f posf( pos );
	Vec3f dirf( dir );
	Vec3f outf;
	bool success = getIntersection( m_terrain, &posf, &dirf, float(maxRange), &outf );

	out.x = outf.x;
	out.y = outf.y;
	out.z = outf.z;

	return success;
}


Vec3 Radar::getNormal( double x, double z )
{
	FNC_GET_NORMAL getNormal = (FNC_GET_NORMAL)find_vfptr_raw( m_terrain, 0x58 );
	Vec3f normf;
	getNormal( m_terrain, &normf, (float)x, (float)z );

	Vec3 norm( normf.x, normf.y, normf.z );
	return norm;
}

double Radar::getRange()
{
	return m_range;
}

Radar::State Radar::getState()
{
	if ( ! m_interface.getElecMonitoredAC() )
		return STATE_OFF;

	switch ( m_modeSwitch )
	{
	case MODE_OFF:
		return STATE_OFF;
	case MODE_STBY:
		return STATE_STBY;
	case MODE_SRCH:
		return STATE_SRCH;
	case MODE_TC:
		if ( ! m_planSwitch )
			return STATE_TC_PLAN;
		else
			return STATE_TC_PROFILE;
	case MODE_AG:
		return STATE_AG;
	}

	return STATE_OFF;
}

double Radar::calculateWarningAngle( double range )
{
	if ( range <= 1000.0_feet )
		return 90.0_deg;

	return asin( 1000.0_feet / range );
}

void Radar::updateObstacleLight( double dt )
{
	m_obstacleTimer += dt;

	//Fix this kinda hacky solution.
	if ( m_state != STATE_TC_PROFILE )
	{
		m_obstacleTimer = 0.0;
		m_obstacleIndicator = false;
		return;
	}

	if ( m_obstacleTimer > c_obstructionPeriod )
	{
		m_obstacleTimer = 0.0;
		m_obstacleIndicator = false;
	}
	else
	{
		double obsTime = c_obstructionPeriod * (1.0 - (m_minObsRange / (20.0_nauticalMile * m_scale)));
		if ( m_obstacleTimer < obsTime )
			m_obstacleIndicator = true;
		else
			m_obstacleIndicator = false;
	}
}

} // end namespace scooter
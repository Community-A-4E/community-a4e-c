#pragma once
#include <Common/Maths.h>
#include "Interface.h"

#define SIDE_LENGTH 50
#define SIDE_HEIGHT 35
#define SIDE_RATIO (double(SIDE_LENGTH)/double(SIDE_HEIGHT))
#define MAX_BLOBS (SIDE_LENGTH * SIDE_HEIGHT)

#define SCREEN_GAIN 1.0

namespace Scooter
{

class RadarScope
{
public:

	enum Scribe
	{
		OFF,
		ON_10,
		ON_20,
	};

	RadarScope( Interface& inter );
	~RadarScope();

	inline void addBlobOpacity( size_t index, double value, double brilliance );
	inline void setBlobOpacity( size_t index, double value );
	inline void setBlob( size_t index, double x, double y, double opacity );
	inline void setBlobPos( size_t index, double x, double y );
	inline void setGlow( bool glow );
	inline void setFilter( bool filter );
	inline void setProfileScribe( Scribe scribe );

	inline void setSideRange( double range );
	inline void setBottomRange( double range );
	inline void setObstacle( bool light, double volume );

	inline void setReticle(double value ) { m_interface.setParamNumber( m_reticle, value ); }

	void addToDisplay( double value );

	void update( double dt );

public:
	Interface& m_interface;

	void** m_xParams;
	void** m_yParams;
	void** m_opacityParams;
	void* m_radarGlow = NULL;
	void* m_filter = NULL;
	void* m_glow = NULL;
	void* m_profile10 = NULL;
	void* m_profile20 = NULL;
	void* m_sideRange = NULL;
	void* m_bottomRange = NULL;
	void* m_obstacleLight = NULL;
	void* m_obstacleVolume = NULL;
	void* m_reticle = NULL;

	bool m_obstacle = false;
};

void RadarScope::addBlobOpacity( size_t index, double value, double brilliance )
{
	double currentValue = m_interface.getParamNumber( m_opacityParams[index] );

	setBlobOpacity( index, clamp(currentValue + value * brilliance, 0.0, SCREEN_GAIN * brilliance ) );
}

void RadarScope::setBlobOpacity( size_t index, double value )
{
	m_interface.setParamNumber( m_opacityParams[index], value );
}

void RadarScope::setBlob( size_t index, double x, double y, double opacity )
{
	m_interface.setParamNumber( m_xParams[index], x );
	m_interface.setParamNumber( m_yParams[index], y );
	m_interface.setParamNumber( m_opacityParams[index], opacity );
}

void RadarScope::setBlobPos( size_t index, double x, double y )
{
	m_interface.setParamNumber( m_xParams[index], x );
	m_interface.setParamNumber( m_yParams[index], y );
}

void RadarScope::setGlow( bool glow )
{
	m_interface.setParamNumber( m_radarGlow, (double)glow );
}

void RadarScope::setFilter( bool filter )
{
	m_interface.setParamNumber( m_filter, (double)filter );
}

void RadarScope::setProfileScribe( Scribe scribe )
{
	switch ( scribe )
	{
	case Scribe::OFF:
		m_interface.setParamNumber( m_profile10, 0.0 );
		m_interface.setParamNumber( m_profile20, 0.0 );
		break;
	case Scribe::ON_10:
		m_interface.setParamNumber( m_profile10, 1.0 );
		m_interface.setParamNumber( m_profile20, 0.0 );
		break;
	case Scribe::ON_20:
		m_interface.setParamNumber( m_profile10, 0.0 );
		m_interface.setParamNumber( m_profile20, 1.0 );
		break;
	}
}

void RadarScope::setSideRange( double range )
{
	m_interface.setParamNumber( m_sideRange, range );
}

void RadarScope::setBottomRange( double range )
{
	m_interface.setParamNumber( m_bottomRange, range );
}

void RadarScope::setObstacle( bool light, double volume )
{
	m_obstacle = light;
	m_interface.setParamNumber( m_obstacleVolume, volume );
}

}
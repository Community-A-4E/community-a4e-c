#include "RadarScope.h"




Scooter::RadarScope::RadarScope( ParameterInterface& inter ) :
	m_interface( inter )
{
	m_xParams = new void*[MAX_BLOBS];
	m_yParams = new void*[MAX_BLOBS];
	m_opacityParams = new void*[MAX_BLOBS];

	char paramName[SIDE_LENGTH];

	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		sprintf_s( paramName, SIDE_LENGTH, "RADAR_BLOB_%llu_LR", i );
		m_xParams[i] = m_interface.api().pfn_ed_cockpit_get_parameter_handle( paramName );


		sprintf_s( paramName, SIDE_LENGTH, "RADAR_BLOB_%llu_UD", i );
		m_yParams[i] = m_interface.api().pfn_ed_cockpit_get_parameter_handle( paramName );

		sprintf_s( paramName, SIDE_LENGTH, "RADAR_BLOB_%llu_OP", i );
		m_opacityParams[i] = m_interface.api().pfn_ed_cockpit_get_parameter_handle( paramName );
	}

	m_radarGlow = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "APG53A_GLOW" );
	m_filter = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "RADAR_FILTER" );
	m_profile10 = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "RADAR_PROFILE_SCRIBE_10NM" );
	m_profile20 = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "RADAR_PROFILE_SCRIBE_20NM" );

	m_sideRange = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "APG53A-LEFTRANGE" );
	m_bottomRange = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "APG53A-BOTTOMRANGE" );

	m_obstacleLight = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "D_GLARE_OBST" );
	m_obstacleVolume = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "APG53_OBST_VOLUME" );
	m_reticle = m_interface.api().pfn_ed_cockpit_get_parameter_handle( "RADAR_RETICLE" );
}

void Scooter::RadarScope::update( double dt )
{
	if ( m_interface.getElecPrimaryAC() )
	{
		m_interface.setParamNumber( m_obstacleLight, (double)(m_interface.getMasterTest() || m_obstacle) );
	}
}

void Scooter::RadarScope::addToDisplay( double value )
{
	for ( size_t i = 0; i < MAX_BLOBS; i++ )
	{
		double currentValue = m_interface.getParamNumber( m_opacityParams[i] );

		setBlobOpacity( i, clamp( currentValue + currentValue * value, 0.0, SCREEN_GAIN ) );
	}
}

Scooter::RadarScope::~RadarScope()
{
	delete[] m_xParams;
	delete[] m_yParams;
	delete[] m_opacityParams;
}
#include "AirDataComputer.h"

#define c_speedOfSound 340.29 //m/s
#define c_standardTemp 288.15 //K
#define c_standardPressure 101325.0 //Pa

Scooter::AirDataComputer::AirDataComputer
(
	ParameterInterface& inter,
	AircraftState& state
) :
	m_interface( inter ),
	m_state( state )
{

}

void Scooter::AirDataComputer::calculateTAS()
{

	m_tas = c_speedOfSound * m_pitot_damage->GetIntegrity() * m_state.getMeasuredMach() * sqrt( m_state.getTemperature() / c_standardTemp );
}

void Scooter::AirDataComputer::calculateEAS()
{
	m_eas = c_speedOfSound * m_pitot_damage->GetIntegrity() * m_state.getMeasuredMach() * sqrt( m_static_damage->GetIntegrity() * m_state.getPressure() / c_standardPressure );
}

void Scooter::AirDataComputer::calculateCAS()
{
	double d = m_static_damage->GetIntegrity() * m_state.getPressure() / c_standardPressure;
	double M = m_state.getMeasuredMach() * m_pitot_damage->GetIntegrity();
	m_cas = m_eas * (1.0 + 0.125 * (1.0 - d) * M * M + (3.0 / 640.0 * (1.0 - 10.0 * d + 9 * d * d) * M * M * M * M));
}

void Scooter::AirDataComputer::calculateBaroAlt()
{
	double p = m_static_damage->GetIntegrity() * m_state.getPressure();
	m_baroAlt = 44330 * (1.0 - pow( p / m_interface.getAltSetting() ,  1.0 / 5.255 ));
}

#define mps_to_knot 1.94384

void Scooter::AirDataComputer::update(double dt)
{
	calculateTAS();
	calculateEAS();
	calculateCAS();
	calculateBaroAlt();

	m_tas_acceleration = ( m_tas - m_tas_prev ) / dt;
	m_tas_prev = m_tas;

	m_interface.ADC_setTAS( m_tas );
	m_interface.ADC_setCAS( m_cas );
	m_interface.ADC_setAlt( m_baroAlt );
	m_interface.ADC_setMeasuredMach( m_state.getMeasuredMach() * m_pitot_damage->GetIntegrity() );
	//printf( "TAS: %lf, EAS: %lf, IAS: %lf\n", mps_to_knot * m_tas, mps_to_knot * m_eas, mps_to_knot * m_cas );
}


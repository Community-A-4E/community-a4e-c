//=========================================================================//
//
//		FILE NAME	: Engine2.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Class for engine simulation, this uses lookup tables for
//						static thrust values with second order dynamics to provide
//						transient response. The static thrust at sea level are then
//						corrected for pressure and temperature.
//
//================================ Includes ===============================//
#include "Engine2.h"
#include <Common/Commands.h>
//=========================================================================//

Scooter::Engine2::Engine2(AircraftState& aircraftState) :
	m_aircraftState(aircraftState),
	fuelToHPOmega( c_fuelToHPOmega, c_fuelToHPOmegaMin, c_fuelToHPOmegaMax ),
	lpOmegaToMassFlow( c_lpOmegaToMassFlow, c_lpOmegaToMassFlowMin, c_lpOmegaToMassFlowMax ),
	hpOmegaToMassFlow( c_hpOmegaToMassFlow, c_hpOmegaToMassFlowMin, c_hpOmegaToMassFlowMax ),
	massFlowToStaticThrust( c_massFlowToStaticThrust, c_massFlowToStaticThrustMin, c_massFlowToStaticThrustMax ),
	airspeedToHPOmega( c_windmill, c_windmillMin, c_windmillMax ),
	thrustToFFOverSqrtTemp ( c_thrustToFFOverSqrtTemp, c_thrustToFFOverSqrtTempMin, c_thrustToFFOverSqrtTempMax ),
	lpInertia( c_lpInertiaTable, 0.0, c_maxHPOmega ),
	hpInertia( c_hpInertiaTable, 0.0, c_maxLPOmega ),
	windmillInertiaFactor( c_windmillInertiaFactor, 0.0, c_maxHPOmega ),
	m_compressorDamageVary(0.0, 10.0),
	m_fuelControllerDamageVary(0.0, 3.0 )
{
	zeroInit();
}

Scooter::Engine2::~Engine2()
{

}

void Scooter::Engine2::zeroInit()
{
	m_lpOmega = 0.0;
	m_hpOmega = 0.0;
	m_throttle = 0.0;
	m_fuelFlow = 0.0;
	m_correctedFuelFlow = 0.0;
	m_massFlow = 0.0;
	m_thrust = 0.0;
	m_hasFuel = true;
	m_ignitors = false;
	m_bleedAir = false;
	m_airspeed = 0.0;
	m_temperature = 15.0 + 273.0;
	m_errPrev = 0.0;
	m_errAcc = 0.0;
}

void Scooter::Engine2::coldInit()
{
	zeroInit();
}

void Scooter::Engine2::hotInit()
{
	zeroInit();
	m_hpOmega = c_maxHPOmega * 0.55;
	m_lpOmega = hpOmegaToLPOmega( m_hpOmega );
	m_ignitors = true;
}

void Scooter::Engine2::airborneInit()
{
	zeroInit();
	m_hpOmega = c_maxHPOmega * 0.70;
	m_lpOmega = hpOmegaToLPOmega( m_hpOmega );
	m_ignitors = true;
}

bool Scooter::Engine2::handleInput( int command, float value )
{
	switch ( command )
	{
	case DEVICE_COMMANDS_ENGINE_FUEL_CONTROL_SW:
		printf( "FUEL SWITCH: %lf\n", value );
		m_manualFuelControl = value == 1.0;
		return true;
	}

	return false;
}

void Scooter::Engine2::updateEngine( double dt )
{
	double correctedThrottle = 0.0;
	if ( m_throttle >= 0.0 )
	{
		correctedThrottle = (1 - c_throttleIdle) * m_throttle + c_throttleIdle;
	}
	else
	{
		correctedThrottle = (m_throttle + 1.0) / 2.0;
	}

	double lowOmegaInertia = 1.0;

	//This gives the engine a sluggish feeling when starting up due to the
	//low thrust produced when starting.
	if ( getRPMNorm() < 0.50 )
	{
		lowOmegaInertia = 7.0;
	}

	//Thrust or Drag
	double thrustSign = 1.0;

	if ( m_hasFuel && m_ignitors )
	{
		double desiredFractionalOmega = 0.0;
		double inertiaFactor = 1.0;
		
		if ( m_throttle >= -0.01 )
		{
			//Normal engine operation
			desiredFractionalOmega = (1 - c_throttleIdle) * m_throttle + c_throttleIdle;
		}
		else
		{
			//Throttle is in 1st detent.
			desiredFractionalOmega = (m_throttle + 1.0) / 1.5;

			//inertiaFactor = desiredFractionalOmega > m_hpOmega / c_maxHPOmega ? 1.0 : 2.0;
		}

		m_fuelControllerDamageVary.setScale( 1.0 );
		double fuelDamage = 1.0;//(1.0 - m_fuelControllerDamageVary.update( dt ));

		//printf( "Damage: %lf\n", fuelDamage );

		double desiredFuelFlow;

		if ( ! m_manualFuelControl )
			desiredFuelFlow = getPID( desiredFractionalOmega, dt ) * fuelDamage;
		else
			desiredFuelFlow = m_throttle * (c_fuelFlowMax * 1.1) + 0.01;

		//m_fuelFlow = desiredFuelFlow;
		//Update towards desired fuel flow with response time.
		//m_fuelFlow = m_throttle;

		

		double desired = clamp( desiredFuelFlow, 0.0, c_fuelFlowMax );

		if ( getRPMNorm() < 0.52 )
		{
			desired *= 0.3 * getRPMNorm();
		}


		m_fuelFlow += (desired - m_fuelFlow) * dt / c_fuelFlowInertia;

		m_compressorDamageVary.setScale( 0.05 * pow( m_damage_engine->GetDamage(), 0.25 ) );
		const double drag = 1.0 - m_compressorDamageVary.update( dt );
		m_fuelFlow *= drag;

		//If we have a boost pump failure we cannot maintain the flow.
		m_fuelFlow = clamp( m_fuelFlow, 0.0, m_maxDeliverableFuelFlow );

		//printf( "FF %lf\n", m_fuelFlow * 2.2 * 3600.0 );
		//m_fuelFlow += (std::max( std::min( desiredFuelFlow, c_fuelFlowMax ), 0.0 ) - m_fuelFlow) * dt / c_fuelFlowInertia;
	}
	else if ( m_bleedAir )
	{
		m_fuelFlow = 0.0;
		//Constant shaft Speed (bleed air from ground huffer)
		//updateShaftsDynamic( dt );
	}
	else
	{
		//We are creating drag
		thrustSign = -1.0;
		
		m_fuelFlow = 0.0;

		//Airspeed -> Shaft Speed (Windmilling)
		//updateShaftsDynamic( dt );
	}

	

	if ( getRPMNorm() > 0.52 && m_ignitors && m_hasFuel )
	{
		//Fuel Flow -> Shaft Speed
		
		//printf( "Integrity: %lf, Damage: %lf\n", m_integrity, drag );

		double expectedOmega = fuelToHPOmega( m_fuelFlow ) * m_inlet_damage->GetIntegrity();
		m_compressorAOA = expectedOmega - m_hpOmega;
		//printf( "Compressor AOA: %lf\n", m_compressorAOA );

		m_compressorStalled = m_compressorAOA > c_compressorStallAOA;

		updateShafts( expectedOmega, 1.0, dt );
	}
	else
	{
		m_compressorStalled = false;
		updateShaftsDynamic( dt );
	}

	//Mass flow is the average of the mass flows from hp and lp shafts.
	m_massFlow = (lpOmegaToMassFlow( m_lpOmega ) + hpOmegaToMassFlow( m_hpOmega )) / 2.0;

	double massFlowFactor =  (m_aircraftState.getAirDensity() / c_standardDayDensity);
	//printf( "Mass Flow Factor: %lf\n", massFlowFactor );
	//Thrust = staticThrust - massFlow * airspeed
	m_thrust = ( 1000.0*massFlowToStaticThrust( m_massFlow ) - abs( m_airspeed ) * m_massFlow) * massFlowFactor * thrustSign;

	//Correct fuel flow for temperature.
	double factor = (m_aircraftState.getPressure() / c_standardDayPressure) * sqrt( m_aircraftState.getTemperature() ) / c_sqrtStandardDayTemp;
	//printf( "Factor: %lf\n", factor );
	m_correctedFuelFlow = m_fuelFlow * factor;
}
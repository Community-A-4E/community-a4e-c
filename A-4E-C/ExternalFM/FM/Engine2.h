#pragma once
#ifndef ENGINE_2_H
#define ENGINE_2_H
//=========================================================================//
//
//		FILE NAME	: Engine2.h
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
#include "BaseComponent.h"
#include "Table.h"
#include "Input.h"
#include "Data.h"
#include <Common/Maths.h>
#include "AircraftState.h"
#include <algorithm>
#include "SmoothVary.h"
#include "Damage.h"
#include "DamageCells.h"
//=========================================================================//

#undef max
#undef min

#define c_lpInertia 500.0
#define c_hpInertia 2.0

#define c_hpInertiaTable {6.0, 12.0, 30.0, 25.0, 23.0, 10.0, 4.0, 3.5, 3.0, 3.0}
#define c_lpInertiaTable c_hpInertiaTable
#define c_windmillInertiaFactor {1.0, 0.5, 1.0, 1.0}

#define c_fuelFlowInertia 1.5

#define c_combustionTorque 720.0
#define c_startTorque 30.0
#define c_airspeedTorque 0.3
#define c_engineDrag 0.1

#define c_compressorStallAOA 300.0

namespace Scooter
{

class Engine2 : public BaseComponent
{
public:
	Engine2(AircraftState& aircraftState);
	~Engine2();

	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();

	bool handleInput( int command, float value );

	inline void setThrottle(double throttle);
	inline void setHasFuel( bool hasFuel );
	inline void setAirspeed( double airspeed );
	inline void setBleedAir( bool bleedAir );
	inline void setIgnitors( bool ignitors );
	inline void setTemperature( double temperature );
	inline void setCompressorDamage( double damage );
	inline void setTurbineDamage( double damage );
	inline void setIntegrity( double integrity );
	inline void setMaxDeliverableFuelFlowFraction( double fraction );

	inline double getThrust();
	inline double getFuelFlow();
	inline double getPID( double desiredFractionalRPM, double dt );
	inline double getRPMNorm();
	inline double getRPM();
	inline bool stalled();

	void updateEngine( double dt );
private:

	std::shared_ptr<DamageObject> m_damage_engine = DamageProcessor::MakeDamageObjectMultiple( "Engine", {
		DamageCell::FUSELAGE_BOTTOM,
		DamageCell::FUSELAGE_LEFT_SIDE,
		DamageCell::FUSELAGE_RIGHT_SIDE
	} );

	std::shared_ptr<DamageObject> m_inlet_damage = DamageProcessor::MakeDamageObject( "Engine Inlet", DamageCell::ENGINE );

	AircraftState& m_aircraftState;
	ZeroTable thrustToFFOverSqrtTemp;
	ZeroTable fuelToHPOmega;
	ZeroTable airspeedToHPOmega;

	ZeroTable lpOmegaToMassFlow;
	ZeroTable hpOmegaToMassFlow;

	ZeroTable massFlowToStaticThrust;

	Table lpInertia;
	Table hpInertia;
	Table windmillInertiaFactor;

	double m_lpOmega = 0.0;
	double m_hpOmega = 0.0;

	double m_lpOmegaDot = 0.0;
	double m_hpOmegaDot = 0.0;

	double m_lpOmegaErrorPrev = 0.0;
	double m_hpOmegaErrorPrev = 0.0;

	double m_throttle = 0.0;
	double m_fuelFlow = 0.0;
	double m_correctedFuelFlow = 0.0;
	double m_maxDeliverableFuelFlow = c_fuelFlowMax;

	double m_massFlow = 0.0;
	double m_thrust = 0.0;

	bool m_hasFuel = true;
	bool m_ignitors = true;
	bool m_bleedAir = false;

	SmoothVary m_compressorDamageVary;
	SmoothVary m_fuelControllerDamageVary;
	double m_compressorDamage = 0.0;
	double m_turbineDamage = 0.0;
	double m_integrity = 0.0;

	double m_compressorAOA = 0.0;
	bool m_compressorStalled = false;

	bool m_started = false;

	bool m_manualFuelControl = false;

	//Environment
	double m_airspeed = 0.0;
	double m_temperature = 15.0 + 273.0;

	//PID
	double m_pGain = 3.0;
	double m_iGain = 10.0;//10.0;
	double m_dGain = 4.5;// 3.8;
	double m_errPrev = 0.0;
	double m_errAcc = 0.0;

	static inline double hpOmegaToLPOmega( double hpOmega );

	inline void updateShafts(double hpTarget, double lowOmegaInertia, double dt);
	inline void updateShaftsDynamic( double dt );
};

void Engine2::setMaxDeliverableFuelFlowFraction( double fraction )
{
	m_maxDeliverableFuelFlow = c_fuelFlowMax * fraction;
}

void Engine2::setThrottle( double throttle )
{
	m_throttle = throttle;
}

void Engine2::setHasFuel( bool hasFuel )
{
	m_hasFuel = hasFuel;
}

void Engine2::setAirspeed( double airspeed )
{
	m_airspeed = airspeed;
}

void Engine2::setBleedAir( bool bleedAir )
{
	m_bleedAir = bleedAir;
}

void Engine2::setIgnitors( bool ignitors )
{
	m_ignitors = ignitors;
}

void Engine2::setTemperature( double temperature )
{
	m_temperature = temperature;
}

double Engine2::getRPMNorm()
{
	return m_hpOmega / c_maxHPOmega;
}

double Engine2::getRPM()
{
	return 60.0 * m_hpOmega / (2.0 * PI);
}

double Engine2::getThrust()
{
	return m_thrust;
}

double Engine2::getFuelFlow()
{
	return m_correctedFuelFlow;
}

double Engine2::getPID( double desiredFractionalRPM, double dt )
{
	//Error between setpoint and process variable
	double error = c_maxHPOmega * desiredFractionalRPM - m_hpOmega;

	//dError * dt
	m_errAcc += error * dt;
	m_errAcc = clamp( m_errAcc, -0.1, 0.1 );

	//printf( "i error %lf\n", m_errAcc );

	//dError/dt
	double errDeriv = (error - m_errPrev) / dt;
	m_errPrev = error;

	//     proportional          integral             derrivative
	return error * m_pGain + m_errAcc * m_iGain + errDeriv * m_dGain;
}

bool Engine2::stalled()
{
	return m_compressorStalled;
}

double Engine2::hpOmegaToLPOmega( double x )
{
	//This function was found using python this is just a 4th order polynomial fit. These magic numbers are the coefficients that came out.
	return -2.46586697e-09 * pow( x, 4.0 ) + 7.31933906e-06 * pow( x, 3.0 ) - 6.38483117e-03 * pow( x, 2.0 ) + 2.25049813 * x;
}

void Engine2::updateShaftsDynamic( double dt )
{
	double effectiveAirspeed = m_airspeed > 30.0 ? m_airspeed : 0.0;
	const double drag = 1.0 - m_compressorDamageVary.update( dt );
	double torque = (double)m_bleedAir * c_startTorque + m_inlet_damage->GetIntegrity() * m_fuelFlow * c_combustionTorque + effectiveAirspeed * c_airspeedTorque - (m_hpOmega + m_lpOmega) * c_engineDrag;

	m_hpOmega += dt * torque / c_hpInertia;
	m_hpOmega = std::max( m_hpOmega, 0.0 );

	m_lpOmega += (hpOmegaToLPOmega( m_hpOmega ) - m_lpOmega) * dt / (lpInertia( m_lpOmega ));
}

void Engine2::updateShafts( double hpTarget, double inertiaFactor, double dt )
{
	

	double hpError = (hpTarget - m_hpOmega);
	double lpError = (hpOmegaToLPOmega( m_hpOmega ) - m_lpOmega);

	if ( ! m_started )
	{
		m_hpOmegaErrorPrev = hpError;
		m_lpOmegaErrorPrev = lpError;
		m_started = true;
	}

	double hpErrorDot = (m_hpOmegaErrorPrev - hpError);
	double lpErrorDot = (m_lpOmegaErrorPrev - lpError);
	
	//1.0 134.0 0.21
	//1 400 0.13
	double hpAccel = (hpError - hpErrorDot * 500.0) * 0.20;
	double lpAccel = (lpError - lpErrorDot * 500.0) * 0.20;

	m_hpOmegaDot += dt * hpAccel;
	m_lpOmegaDot += dt * lpAccel;

	m_hpOmega += dt * m_hpOmegaDot;
	m_lpOmega += dt * m_lpOmegaDot;


	//m_hpOmega += dt * ((hpErrorDot) + (hpError / hpInertia(m_hpOmega))) / inertiaFactor;
	//m_lpOmega += dt * ((lpErrorDot) + (lpError / lpInertia(m_lpOmega))) / inertiaFactor;

	//printf( "Error dot %lf, Regular %lf\n", hpErrorDot, (hpError / hpInertia( m_hpOmega )) );

	m_hpOmegaErrorPrev = hpError;
	m_lpOmegaErrorPrev = lpError;
}

void Engine2::setCompressorDamage( double damage )
{
	m_compressorDamage = damage;
}

void Engine2::setTurbineDamage( double damage )
{
	m_turbineDamage = damage;
}

void Engine2::setIntegrity( double integrity )
{
	m_integrity = integrity;
}

}
#endif
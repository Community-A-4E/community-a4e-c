#pragma once
#ifndef AVIONICS_H
#define AVIONICS_H
//=========================================================================//
//
//		FILE NAME	: Avionics.h
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Avionics class handles the any C/C++ side avionics. This
//						is the the yaw damper and the CP741/A bombing computer.
//
//================================ Includes ===============================//
#include <Common/Maths.h>
#include "BaseComponent.h"
#include "Input.h"
#include "AircraftState.h"
#include "CP741.h"
#include "Interface.h"
#include "AirDataComputer.h"
#include "Gyro.h"
//=========================================================================//

namespace Scooter
{//begin namespace

class Avionics : public BaseComponent
{
public:
	Avionics(Input& input, AircraftState& state, Interface& inter);
	~Avionics();
	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();

	void updateAvionics(double dt);
	inline void setYawDamperPower( bool power );
	inline bool getValidBombingSolution();
	inline bool getOxygen();
	
	bool handleInput( int command, float value );

	inline CP741& getComputer();

	void SetAJB3Output( double dt ) const;
	void SetStandbyADIOutput( double dt ) const;
	void SetADIOutput( double dt ) const;
private:

	void ImGuiDebugWindow();

	//constants
	const double m_timeConstant = 4.5; //was 4.5
	const double m_baseGain = 2.5;

	inline double washoutFilter(double input, double dt);
	double m_x = 0.0;

	Input& m_input;
	AircraftState& m_state;
	Interface& m_interface;

	CP741 m_bombingComputer;
	AirDataComputer m_adc;

	// 0.001
	// 0.0
	// 1.0
	// 0.01
	// 0.01
	// 0.0


	Gyro::Variables m_ajb3_settings = {
		0.5,
		0.07,
		100.0,
		8000.0_rpm,
		DamageCell::TAIL_LEFT_SIDE,
		"AJB-3 Gyro",
		1.0e-4,
		0.001,
		0.01,
		0.01,
		0.0, // Precision instrument
		40.0,
		60.0,
	};
	Gyro m_gyro_ajb3;

	Gyro::Variables m_standby_adi_settings = {
		0.2, // Rotor Mass
		0.035, // Radius
		100.0, // RPM Factor
		6000.0_rpm, // operating Omega
		DamageCell::NOSE_RIGHT_SIDE,
		"Standby ADI Gyro",
		1.0e-4, // Gimbal Friction
		0.001,
		0.1, // Erection Rate
		0.01,
		1.0e-4, // Random Torque
		40.0, // Spin Down
		60.0, // Spin Up
	};
	Gyro m_standby_adi;

	static constexpr bool advanced_gyro_enabled = false;

	bool m_damperEnabled = false;

	bool m_oxygen = true;

	std::uniform_real_distribution<double> distribution{ 0.0, 1.0 };
	std::mt19937 generator{ 444 };
};

bool Avionics::getOxygen()
{
	return m_oxygen;
}

double Avionics::washoutFilter(double input, double dt)
{
	double sampleRatio = dt / m_timeConstant;
	m_x = clamp((1.0 - (sampleRatio)) * m_x + sampleRatio * input, -0.1,0.1);
	return input - m_x;
}

void Avionics::setYawDamperPower( bool power )
{
	m_damperEnabled = power;
}

bool Avionics::getValidBombingSolution()
{

}

CP741& Avionics::getComputer()
{
	return m_bombingComputer;
}

}//end namespace
#endif
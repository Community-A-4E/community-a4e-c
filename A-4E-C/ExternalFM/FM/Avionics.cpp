//=========================================================================//
//
//		FILE NAME	: Avionics.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Avionics class handles the any C/C++ side avionics. This
//						is the the yaw damper and the CP741/A bombing computer.
//
//================================ Includes ===============================//
#include "Avionics.h"

#include <corecrt_math_defines.h>

#include <Common/Maths.h>
#include <Common/Devices.h>
#include "Commands.h"
#include "cockpit_base_api.h"
//#include <LuaImGui.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include "Units.h"
//=========================================================================//

#define STAB_AUG_MAX_AUTHORITY 0.3
#define MAX_ROTATION_RATE 1.6

Scooter::Avionics::Avionics
(
	Input& input,
	AircraftState& state,
	Interface& inter
) :
	m_input(input),
	m_state(state),
	m_interface(inter),
	m_bombingComputer(state),
	m_adc(inter, state),
    m_gyro_ajb3( m_ajb3_settings ),
    m_standby_adi(m_standby_adi_settings)
{
	zeroInit();

	//LuaImGui::AddImGuiItem( "Avionics", "General", [this]() { ImGuiDebugWindow(); } );
}

Scooter::Avionics::~Avionics()
{

}

//Seriously need to set EVERY VARIABLE to zero (or approriate value if zero causes singularity) in the constructor and 
//in this function. Otherwise Track's become unusable because of the butterfly effect.
void Scooter::Avionics::zeroInit()
{
	m_x = 0.0;
}

void Scooter::Avionics::coldInit()
{
	zeroInit();
	ed_cockpit_dispatch_action_to_device( DEVICES_AVIONICS, DEVICE_COMMANDS_OXYGEN_SWITCH, 0.0 );
	m_gyro_ajb3.ColdStart();
	m_standby_adi.ColdStart();
}

void Scooter::Avionics::hotInit()
{
	zeroInit();
	ed_cockpit_dispatch_action_to_device( DEVICES_AVIONICS, DEVICE_COMMANDS_OXYGEN_SWITCH, 1.0 );
	m_gyro_ajb3.HotStart();
	m_standby_adi.HotStart();
}

void Scooter::Avionics::airborneInit()
{
	zeroInit();
	ed_cockpit_dispatch_action_to_device( DEVICES_AVIONICS, DEVICE_COMMANDS_OXYGEN_SWITCH, 1.0 );
	m_gyro_ajb3.HotStart();
	m_standby_adi.HotStart();
}

bool Scooter::Avionics::handleInput( int command, float value )
{
	switch ( command )
	{
	case DEVICE_COMMANDS_OXYGEN_SWITCH:
		m_oxygen = (value == 1.0f);
		return true;
	}

	return false;
}

void Scooter::Avionics::updateAvionics(double dt)
{

	//printf( "Omega.y: %lf\n", m_state.getOmega().y );
	if ( m_damperEnabled )
	{
		double omega = m_state.getOmega().y;
		if ( fabs( omega ) > MAX_ROTATION_RATE )
		{
			omega = 0.0;
		}


		double f = washoutFilter( omega, dt ) * m_baseGain * (1.0 / (m_state.getMach() + 1));
		m_input.yawDamper() = clamp(f,-STAB_AUG_MAX_AUTHORITY, STAB_AUG_MAX_AUTHORITY); //f
	}
	else
	{
		m_x = 0.0;  
		m_input.yawDamper() = 0.0;
	}
	m_bombingComputer.updateSolution();
	m_adc.update(dt);

	// Turn this shit off for now
	// Revisit in future, maybe force the erection rate like by physically moving the angular velocity
	// instead of applying torques.
	if ( advanced_gyro_enabled )
	{
		const double tas_acceleration = m_adc.GetTASAcceleration();
		const double x_acceleration = tas_acceleration * cos( m_state.getAOA() );
		const double z_acceleration = tas_acceleration * sin( m_state.getAOA() );
		Gyro::Vec3 adc_compensation = { x_acceleration, 0.0, z_acceleration };

		Gyro::Vec3 local_acceleration;
		const Vec3& local_acceleration_state = m_state.getLocalAcceleration();
		local_acceleration.x() = local_acceleration_state.x;
		local_acceleration.y() = local_acceleration_state.z;
		local_acceleration.z() = local_acceleration_state.y;

		const Vec3& omega_state = m_state.getOmega();
		Gyro::Vec3 local_omega;
		local_omega.x() = omega_state.x;
		local_omega.y() = omega_state.z;
		local_omega.z() = omega_state.y;

		m_gyro_ajb3.SetElectricalPower( m_interface.getElecPrimaryAC() );
		m_gyro_ajb3.Update( dt, m_state.GetOrientation(), local_acceleration - adc_compensation, local_omega );

		m_standby_adi.SetElectricalPower( m_interface.getElecPrimaryAC() );
		m_standby_adi.Update( dt, m_state.GetOrientation(), local_acceleration, local_omega );

		SetADIOutput( dt );
	}

	//ed_cockpit_set_draw_argument( 385, static_cast<float>( yaw ) );

	//printf("Filter: %lf, Rudder: %lf\n", f, m_flightModel.yawRate());
}

void Scooter::Avionics::SetAJB3Output( double dt ) const
{
	double pitch = 0.0;
	double roll = 0.0;
	m_gyro_ajb3.GetPitchRoll( pitch, roll );

	pitch /= 90.0;
	roll /= 180.0;

	if ( isnan( pitch ) )
		pitch = 0.0;

	if ( isnan( roll ) )
		roll = 0.0;

	ed_cockpit_set_draw_argument( 384, static_cast<float>( roll ) );
	ed_cockpit_set_draw_argument( 383, static_cast<float>( pitch ) );

	const bool operating = m_gyro_ajb3.PercentSpinUp() > 0.9 && m_gyro_ajb3.Operating() && ! m_gyro_ajb3.FastErect();
	static constexpr int flag_arg = 387;
	float current_argument = ed_cockpit_get_draw_argument( flag_arg );
	const float target = ! operating;
	current_argument += ( target - current_argument ) * float(dt) / 2.0f;
	ed_cockpit_set_draw_argument( flag_arg, current_argument );
}


void Scooter::Avionics::SetStandbyADIOutput( double dt ) const
{
	double pitch = 0.0;
	double roll = 0.0;
	m_standby_adi.GetPitchRoll( pitch, roll );

	pitch /= 90.0;
	roll /= 180.0;

	if ( isnan( pitch ) )
		pitch = 0.0;

	if ( isnan( roll ) )
		roll = 0.0;

	ed_cockpit_set_draw_argument( 661, static_cast<float>( roll ) );
	ed_cockpit_set_draw_argument( 660, static_cast<float>( pitch ) );

	const bool operating = m_standby_adi.PercentSpinUp() > 0.9 && m_standby_adi.Operating();
	static constexpr int flag_arg = 664;
	float current_argument = ed_cockpit_get_draw_argument( flag_arg );
	const float target = ! operating;
	current_argument += ( target - current_argument ) * float(dt) / 2.0f;
	ed_cockpit_set_draw_argument( flag_arg, current_argument );

}

void Scooter::Avionics::SetADIOutput( double dt ) const
{
	SetAJB3Output(dt);
	SetStandbyADIOutput(dt);
}

void Scooter::Avionics::ImGuiDebugWindow()
{
	/*if ( ImGui::TreeNode("AJB-3 (Pitch/Roll) Gyro") )
	{
		m_gyro_ajb3.ImguiDebugWindow();
		ImGui::TreePop();
	}

	if ( ImGui::TreeNode( "Standby ADI Gyro" ) )
	{
		m_standby_adi.ImguiDebugWindow();
		ImGui::TreePop();
	}*/
	
}

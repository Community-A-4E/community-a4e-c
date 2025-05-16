//=========================================================================//
//
//		FILE NAME	: Airframe.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Airframe class handles the current state of each parameter
//						for the airframe. This includes things like fuel, control
//						surfaces and damage.
//
//================================ Includes ===============================//
#include "Airframe.h"
#include <algorithm>
//#include <LuaImGui.h>
//=========================================================================//

Scooter::Airframe::Airframe(AircraftState& state, Input& controls, Engine2& engine) :
	m_state(state),
	m_controls(controls),
	m_engine(engine)
{
	m_integrityElement = new float[(int)Damage::COUNT];
	zeroInit();

	m_damageStack.reserve( 10 );

	//LuaImGui::AddImGuiItem( "Airframe", "Catapult", [this] { ImGuiDebugWindow(); } );

}

Scooter::Airframe::~Airframe()
{
	delete[] m_integrityElement;
}

void Scooter::Airframe::printDamageState()
{
	printf( "===========================================\n" );

	printf( "            ||\n" );
	printf( "            ||\n" );
	printf( "%.1lf %.1lf %.1lf || %.1lf %.1lf %.1lf\n", 
		DMG_ELEM(Damage::WING_L_OUT), 
		DMG_ELEM(Damage::WING_L_CENTER), 
		DMG_ELEM(Damage::WING_L_IN),
		DMG_ELEM( Damage::WING_R_IN ),
		DMG_ELEM( Damage::WING_R_CENTER ),
		DMG_ELEM( Damage::WING_R_OUT ) );

	printf( "        %.1f || %.1f\n", DMG_ELEM(Damage::AILERON_L), DMG_ELEM(Damage::AILERON_R) );
	printf( "            ||\n" );
	printf( "        %.1f || %.1f\n", DMG_ELEM( Damage::STABILIZATOR_L ), DMG_ELEM( Damage::STABILIZATOR_R ) );
	printf( "        %.1f || %.1f\n", DMG_ELEM( Damage::ELEVATOR_L ), DMG_ELEM( Damage::ELEVATOR_R ) );
	printf( "            %.1f\n", getVertStabDamage() );
	printf( "            %.1f\n", getRudderDamage() );
}

void Scooter::Airframe::resetDamage()
{
	for ( int i = 0; i < (int)Damage::COUNT; i++ )
	{
		m_integrityElement[i] = 1.0f;
	}
}

//Seriously need to set EVERY VARIABLE to zero (or approriate value if zero causes singularity) in the constructor and 
//in this function. Otherwise Track's become unusable because of the butterfly effect.
void Scooter::Airframe::zeroInit()
{
	m_gearLPosition = 0.0;
	m_gearRPosition = 0.0;
	m_gearNPosition = 0.0;

	m_flapsPosition = 0.0;
	m_spoilerPosition = 0.0;
	m_speedBrakePosition = 0.0;
	m_hookPosition = 0.0;
	m_slatLPosition = 0.0;
	m_slatRPosition = 0.0;

	m_aileronLeft = 0.0;
	m_aileronRight = 0.0;
	m_elevator = 0.0;
	m_rudder = 0.0;
	m_stabilizer = 0.0;
	m_noseWheelAngle = 0.0;

	resetDamage();

	m_mass = 1.0;


	m_catapultState = CatapultState::OFF_CAT;
	m_catStateSent = false;
	m_catMoment = 0.0;
	m_angle = 0.0;
	m_noseCompression = 0.0;

	m_damageStack.clear();
	m_slatsLocked = false;
}

void Scooter::Airframe::coldInit()
{
	zeroInit();
}

void Scooter::Airframe::hotInit()
{
	zeroInit();
}

void Scooter::Airframe::airborneInit()
{
	zeroInit();
}

static double CalculateWheelArgChange( double arg_now, double arg_prev )
{
	double darg_big = ( 1.0 - arg_prev ) + arg_now;
	double darg_small = ( arg_now - arg_prev );

	if ( abs( darg_big ) < abs( darg_small ) )
		return darg_big;
	else
		return darg_small;
}

void Scooter::Airframe::airframeUpdate(double dt)
{
	//printf( "I %lf, L %lf, C %lf, R %lf\n", m_fuel[0], m_fuel[1], m_fuel[2], m_fuel[3] );

	if (m_controls.hook())
	{
		m_hookPosition += dt / m_hookExtendTime;
		m_hookPosition = std::min(m_hookPosition, 1.0);
	}
	else
	{
		m_hookPosition -= dt / m_hookExtendTime;
		m_hookPosition = std::max(m_hookPosition, 0.0);
	}

	static constexpr double wheel_radius = 0.609;
	static constexpr double wheel_factor = 2.0 * PI * wheel_radius;
	m_left_wheel_speed = wheel_factor * CalculateWheelArgChange( m_left_wheel_arg, m_left_wheel_arg_prev ) / dt;
	m_right_wheel_speed = wheel_factor * CalculateWheelArgChange( m_right_wheel_arg, m_right_wheel_arg_prev ) / dt;

	m_left_wheel_arg_prev = m_left_wheel_arg;
	m_right_wheel_arg_prev = m_right_wheel_arg;

	//const Vec3 gravity_force = m_state.getGlobalDownVectorInBody() * m_nose_wheel_mass * 9.81;
	const Vec3 nose_wheel_vector = m_nose_wheel_force_position - m_pivot_position;
	const Vec3 torque = cross( nose_wheel_vector, m_nose_wheel_force );
	const double damping_torque = m_nose_wheel_angular_velocity * m_nose_wheel_damping;

	const double torque_sign = copysign( 1.0, torque.y );
	

	static constexpr double max_breakout_speed = 0.1; //m/s
	const double w = clamp( m_nose_wheel_ground_speed / max_breakout_speed, 0.0, 1.0 );
	const double breakout_torque = lerpWeight( m_break_out_torque, 0.0, w );
	//printf( "Breakout Torque: %lf\n", breakout_torque );
	/*if ( abs(m_nose_wheel_angular_velocity) < 0.01 )
	{
		breakout_torque = m_break_out_torque  ;
	}*/

	const double torque_after_breakout = torque_sign * std::max( abs(torque.y) - breakout_torque, 0.0 );
	const double torque_total = torque_after_breakout - damping_torque;
	m_nose_wheel_angular_velocity += torque_total * dt;
	m_nose_wheel_angle += m_nose_wheel_angular_velocity * dt;
	
	m_nose_wheel_fix = m_catapultState == OFF_CAT && m_nose_wheel_ground_speed < 25.0;
	if ( ! m_nose_wheel_fix )
	{
		m_nose_wheel_angle = 0.0;
	}
	//printf( "torque=%lf,torque_damping=%lf,w=%lf,theta=%lf\n", torque_after_breakout, damping_torque, m_nose_wheel_angular_velocity, m_nose_wheel_angle );
	//printf( "%lf,%lf,%lf\n", m_nose_wheel_force_position.x, m_nose_wheel_force_position.y, m_nose_wheel_force_position.z );

	
	//printf( "L/R: %d, %d, %lf, %lf\n", IsSkiddingLeft(), IsSkiddingRight(), m_left_wheel_ground_speed, m_right_wheel_ground_speed );


	//printf("LEFT: %lf, CENTRE: %lf, RIGHT: %lf, INTERNAL: %lf\n", m_fuel[Tank::LEFT_EXT], m_fuel[Tank::CENTRE_EXT], m_fuel[Tank::RIGHT_EXT], m_fuel[Tank::INTERNAL]);
	//m_engine.setHasFuel(m_fuel[Tank::INTERNAL] > 20.0);

	//printf( "Compressor Damage %lf, Turbine Damage: %lf\n", getCompressorDamage(), getTurbineDamage() );


	//m_engine.setCompressorDamage( getCompressorDamage() );
	//m_engine.setCompressorDamage( 1.0 );
	m_engine.setIntegrity( DMG_ELEM( Damage::ENGINE ) );
	//m_engine.setTurbineDamage( getTurbineDamage() );
	//m_engine.setTurbineDamage( 1.0 );
	
	m_stabilizer = setStabilizer(dt);
	m_elevator = setElevator(dt);
	m_aileronLeft = setAileronLeft(dt);
	m_aileronRight = setAileronRight(dt);
	m_rudder = setRudder(dt);


	if (m_catapultState == ON_CAT_NOT_READY && m_engine.getRPMNorm() > 0.9)
	{
		m_catapultState = ON_CAT_READY;
	}

	

	if (m_catapultState != OFF_CAT)
	{
		if ( m_catapultState != ON_CAT_LAUNCHING )
		{
			m_catAngle = m_state.getAngle().z;
			//m_catMoment = -c_catConstantMoment;
		}
		else
		{
			m_catMoment = -c_catConstantMoment + std::max ( pow( ( m_catAngle - m_state.getAngle().z - 0.07 ) * 60.0, 3.0 ) * c_catConstrainingForce, -500000.0 );
		}
		//printf( "Cat Moment: %lf\n", m_catMoment );
	}
	else
	{
		m_catMoment = 0.0;
		m_catMomentVelocity = 0.0; 
		m_prevAccel = 0.0;
		m_catForce = 0.0;
	}
	//printf("Cat Moment: %lf\n", m_catMoment);

	m_catStateSent = false;

	//printDamageState();
}

//void Scooter::Airframe::ImGuiDebugWindow()
//{
//	ImGui::Text( "Cat State Sent: %s", m_catStateSent ? "Sent" : "Not Sent" );
//
//    switch ( m_catapultState )
//    {
//    case CatapultState::OFF_CAT:
//		ImGui::Text( "Off CAT" );
//		break;
//    case CatapultState::ON_CAT_NOT_READY:
//		ImGui::Text( "On CAT not ready" );
//		break;
//	case CatapultState::ON_CAT_WAITING:
//		ImGui::Text( "On CAT waiting" );
//		break;
//	case CatapultState::ON_CAT_READY:
//		ImGui::Text( "On CAT ready" );
//		break;
//	case CatapultState::ON_CAT_LAUNCHING:
//		ImGui::Text( "On CAT launching" );
//		break;
//
//    }
//
//	if ( ImGui::Button( "Switch Off" ) )
//	{
//		m_catapultState = CatapultState::OFF_CAT;
//	}
//
//	if ( ImGui::Button("Switch Not Ready") )
//	{
//		m_catapultState = CatapultState::ON_CAT_NOT_READY;
//	}
//
//	if ( ImGui::Button( "Switch Waiting" ) )
//	{
//		m_catapultState = CatapultState::ON_CAT_WAITING;
//	}
//
//	if ( ImGui::Button( "Switch Ready" ) )
//	{
//		m_catapultState = CatapultState::ON_CAT_READY;
//	}
//
//	if ( ImGui::Button( "Switch Launching" ) )
//	{
//		m_catapultState = CatapultState::ON_CAT_LAUNCHING;
//	}
//}

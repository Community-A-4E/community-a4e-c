#pragma once
#ifndef AIRFRAME_H
#define AIRFRAME_H
//=========================================================================//
//
//		FILE NAME	: Airframe.h
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
#include "BaseComponent.h"
#include "AircraftState.h"
#include "Actuator.h"
#include "Input.h"
#include <stdio.h>
#include "Engine2.h"
#include <Common/Maths.h>
//=========================================================================//

//Macro police don't hurt me
#define DMG_ELEM(v) m_integrityElement[(int)v]

namespace Scooter
{//begin namespace



#define c_aileronUp 0.35
#define c_aileronDown -0.35

#define c_elevatorUp 0.3
#define c_elevatorDown -0.35

#define c_rudderRight 0.35
#define c_rudderLeft -0.35

#define c_flapUp 0.0
#define c_flapDown 0.52

#define c_speedBrakeIn 0.0
#define c_speedBrakeOut 1.0

#define c_maxfuel 2137.8

#define c_catAngle 0.0
#define	c_catConstrainingForce 4500.0
#define c_catConstantMoment 100000.0



class Airframe : public BaseComponent
{
public:

	enum CatapultState
	{
		ON_CAT_READY,
		ON_CAT_NOT_READY,
		ON_CAT_WAITING,
		ON_CAT_LAUNCHING,
		OFF_CAT
	};

	enum class Damage
	{
		NOSE_CENTER = 0,
		FRONT = 0,
		Line_NOSE = 0,
		NOSE_LEFT_SIDE = 1,
		NOSE_RIGHT_SIDE = 2,
		COCKPIT = 3,
		CABINA = 3,
		CABIN_LEFT_SIDE = 4,
		CABIN_RIGHT_SIDE = 5,
		CABIN_BOTTOM = 6,
		GUN = 7,
		FRONT_GEAR_BOX = 8,
		GEAR_REAR = 8,
		GEAR_C = 8,
		GEAR_F = 8,
		STOIKA_F = 8,
		FUSELAGE_LEFT_SIDE = 9,
		FUSELAGE_RIGHT_SIDE = 10,
		MAIN = 10,
		LINE_MAIN = 10,
		ENGINE = 11,
		ENGINE_L = 11,
		ENGINE_L_VNUTR = 11,
		ENGINE_L_IN = 11,
		ENGINE_R = 12,
		ENGINE_R_VNUTR = 12,
		ENGINE_R_IN = 12,
		MTG_L_BOTTOM = 13,
		MTG_R_BOTTOM = 14,
		LEFT_GEAR_BOX = 15,
		GEAR_L = 15,
		STOIKA_L = 15,
		RIGHT_GEAR_BOX = 16,
		GEAR_R = 16,
		STOIKA_R = 16,
		MTG_L = 17,
		ENGINE_L_VNESHN = 17,
		ENGINE_L_OUT = 17,
		EWU_L = 17,
		MTG_R = 18,
		ENGINE_R_VNESHN = 18,
		ENGINE_R_OUT = 18,
		EWU_R = 18,
		AIR_BRAKE_L = 19,
		AIR_BRAKE_R = 20,
		WING_L_PART_OUT = 21,
		WING_R_PART_OUT = 22,
		WING_L_OUT = 23,
		WING_R_OUT = 24,
		ELERON_L = 25,
		AILERON_L = 25,
		ELERON_R = 26,
		AILERON_R = 26,
		WING_L_PART_CENTER = 27,
		WING_R_PART_CENTER = 28,
		WING_L_CENTER = 29,
		WING_R_CENTER = 30,
		FLAP_L_OUT = 31,
		FLAP_R_OUT = 32,
		WING_L_PART_IN = 33,
		WING_R_PART_IN = 34,
		WING_L_IN = 35,
		WING_L = 35,
		Line_WING_L = 35,
		WING_R_IN = 36,
		WING_R = 36,
		Line_WING_R = 36,
		FLAP_L_IN = 37,
		FLAP_L = 37,
		FLAP_R_IN = 38,
		FLAP_R = 38,
		FIN_L_TOP = 39,
		KEEL_L_OUT = 39,
		KEEL_OUT = 39,
		FIN_R_TOP = 40,
		KEEL_R_OUT = 40,
		FIN_L_CENTER = 41,
		KEEL_L_CENTER = 41,
		KEEL_CENTER = 41,
		FIN_R_CENTER = 42,
		KEEL_R_CENTER = 42,
		FIN_L_BOTTOM = 43,
		KIL_L = 43,
		Line_KIL_L = 43,
		KEEL = 43,
		KEEL_IN = 43,
		KEEL_L = 43,
		KEEL_L_IN = 43,
		FIN_R_BOTTOM = 44,
		KIL_R = 44,
		Line_KIL_R = 44,
		KEEL_R = 44,
		KEEL_R_IN = 44,
		STABILIZER_L_OUT = 45,
		STABILIZATOR_L_OUT = 45,
		STABILIZER_R_OUT = 46,
		STABILIZATOR_R_OUT = 46,
		STABILIZER_L_IN = 47,
		STABILIZATOR_L = 47,
		STABILIZATOR_L01 = 47,
		Line_STABIL_L = 47,
		STABILIZER_R_IN = 48,
		STABILIZATOR_R = 48,
		STABILIZATOR_R01 = 48,
		Line_STABIL_R = 48,
		ELEVATOR_L_OUT = 49,
		ELEVATOR_R_OUT = 50,
		ELEVATOR_L_IN = 51,
		ELEVATOR_L = 51,
		RV_L = 51,
		ELEVATOR_R_IN = 52,
		ELEVATOR_R = 52,
		RV_R = 52,
		RUDDER_L = 53,
		RN_L = 53,
		RUDDER = 53,
		RUDDER_R = 54,
		RN_R = 54,
		TAIL = 55,
		TAIL_LEFT_SIDE = 56,
		TAIL_RIGHT_SIDE = 57,
		TAIL_BOTTOM = 58,
		NOSE_BOTTOM = 59,
		PWD = 60,
		PITOT = 60,
		FUEL_TANK_F = 61,
		FUEL_TANK_LEFT_SIDE = 61,
		FUEL_TANK_B = 62,
		FUEL_TANK_RIGHT_SIDE = 62,
		ROTOR = 63,
		BLADE_1_IN = 64,
		BLADE_1_CENTER = 65,
		BLADE_1_OUT = 66,
		BLADE_2_IN = 67,
		BLADE_2_CENTER = 68,
		BLADE_2_OUT = 69,
		BLADE_3_IN = 70,
		BLADE_3_CENTER = 71,
		BLADE_3_OUT = 72,
		BLADE_4_IN = 73,
		BLADE_4_CENTER = 74,
		BLADE_4_OUT = 75,
		BLADE_5_IN = 76,
		BLADE_5_CENTER = 77,
		BLADE_5_OUT = 78,
		BLADE_6_IN = 79,
		BLADE_6_CENTER = 80,
		BLADE_6_OUT = 81,
		FUSELAGE_BOTTOM = 82,
		WHEEL_F = 83,
		WHEEL_C = 83,
		WHEEL_REAR = 83,
		WHEEL_L = 84,
		WHEEL_R = 85,
		PYLON1 = 86,
		PYLONL = 86,
		PYLON2 = 87,
		PYLONR = 87,
		PYLON3 = 88,
		PYLON4 = 89,
		CREW_1 = 90,
		CREW_2 = 91,
		CREW_3 = 92,
		CREW_4 = 93,
		ARMOR_NOSE_PLATE_LEFT = 94,
		ARMOR_NOSE_PLATE_RIGHT = 95,
		ARMOR_PLATE_LEFT = 96,
		ARMOR_PLATE_RIGHT = 97,
		HOOK = 98,			
		FUSELAGE_TOP = 99,
		TAIL_TOP = 100,
		FLAP_L_CENTER = 101,
		FLAP_R_CENTER = 102	,
		ENGINE_1 = 103,
		ENGINE_2 = 104,
		ENGINE_3 = 105,
		ENGINE_4 = 106,
		ENGINE_5 = 107,
		ENGINE_6 = 108,
		ENGINE_7 = 109,
		ENGINE_8 = 110,
		COUNT = 111,
	};


	struct DamageDelta
	{
		Damage m_element;
		float m_delta;
	};

	//Don't touch this it's order dependent you will break the tank code.
	//enum Tank
	//{
	//	INTERNAL,
	//	LEFT_EXT,
	//	CENTRE_EXT,
	//	RIGHT_EXT,
	//	DONT_TOUCH //Seriously don't touch it.
	//};


	Airframe(AircraftState& state, Input& controls, Engine2& engine);
	~Airframe();
	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();

	//Utility
	inline void setGearLPosition(double position); //for airstart or ground start
	inline void setGearRPosition(double position); //for airstart or ground start
	inline void setGearNPosition(double position); //for airstart or ground start
	inline void setFlapsPosition(double position);
	inline void setSpoilerPosition(double position);
	inline void setSlatLPosition(double position);
	inline void setSlatRPosition(double position);
	inline void setAirbrakePosition(double position);
	void addFuel( double fuel );
	inline void setAngle(double angle);
	inline void setMass(double angle);
	inline void setFuelCapacity( double l, double c, double r );

	inline void setNoseCompression( double x );
	
	//inline void setDumpingFuel( bool dumping );

	inline double setAileronLeft( double dt );
	inline double setAileronRight( double dt );
	inline double setElevator( double dt );
	inline double setRudder( double dt );
	inline double setStabilizer( double dt );

	inline void setNoseWheelAngle( double angle );

	inline double getGearLPosition() const; //returns gear pos
	inline double getGearRPosition() const; //returns gear pos
	inline double getGearNPosition() const; //returns gear pos

	inline double getFlapsPosition() const;
	inline double getSpoilerPosition() const;
	inline double getSpeedBrakePosition() const;
	inline double getHookPosition() const;
	inline double getSlatLPosition() const;
	inline double getSlatRPosition() const;
	inline double getCatMoment() const;
	inline double getCatForce() const;
	inline double getMass() const;
	inline double getAileronLeft() const;
	inline double getAileronRight() const;
	inline double getElevator() const;
	inline double getRudder() const;
	inline double getStabilizer() const;
	inline double getStabilizerAnim() const;
	inline double getNoseWheelAngle() const;


	inline double aileronAngle();
	inline double elevatorAngle();
	inline double rudderAngle();

	inline const CatapultState& catapultState() const;
	inline CatapultState& catapultState();
	inline const bool& catapultStateSent() const;
	inline bool& catapultStateSent();
	inline void setCatStateFromKey();
	inline void setCatAngle( double angle );

	inline void setIntegrityElement(Damage element, float integrity);
	inline float getIntegrityElement(Damage element);
	inline void setDamageDelta( Damage element, float delta );
	inline bool processDamageStack( Damage& element, float& damage );
	inline void setSlatsLocked( bool locked );
	inline void toggleSlatsLocked();

	void resetDamage();

	void printDamageState();

	//Update
	void airframeUpdate(double dt); //performs calculations and updates

	//Damage
	inline float getLWingDamage() const;
	inline float getRWingDamage() const;

	inline float getAileronDamage() const;

	inline float getVertStabDamage() const;
	inline float getRudderDamage() const;

	inline float getHoriStabDamage() const;
	inline float getElevatorDamage() const;

	inline float getCompressorDamage() const;
	inline float getTurbineDamage() const;
	inline float getSpoilerDamage() const;
	inline float getSpeedbrakeDamage() const;
	inline float getFlapDamage() const;
	inline double getNoseCompression() const;

	inline double getDamageElement(Damage element) const;

	inline double getElevatorZeroForceDeflection() const;
	inline bool getSlatsLocked() const;


	inline void SetLeftWheelArg( float value ) { m_left_wheel_arg = value; }
	inline void SetRightWheelArg( float value ) { m_right_wheel_arg = value; }

	void SetNoseWheelGroundSpeed( double value ) { m_nose_wheel_ground_speed = value; }
	inline void SetLeftWheelGroundSpeed( float value ) { m_left_wheel_ground_speed = value; }
	inline void SetRightWheelGroundSpeed( float value ) { m_right_wheel_ground_speed = value; }

	inline void SetCompressionLeft( float value ) { m_left_compression = value; }
	inline void SetCompressionRight( float value ) { m_right_compression = value; }

	inline double GetSlipageLeft() const { return m_left_wheel_ground_speed - m_left_wheel_speed; }
	inline double GetSlipageRight() const { return m_right_wheel_ground_speed - m_right_wheel_speed; }

	bool GetNoseWheelFix() const { return m_nose_wheel_fix; }

	static constexpr double slip_threshold = 0.5;
	static constexpr double compression_threshold = 0.1;
	static constexpr double min_ground_speed = 0.5;
	bool IsSkiddingLeft() const
	{
		if ( ! m_skiddable_surface )
			return false;

		// Not fast enough ground speed
		if ( m_left_wheel_ground_speed < min_ground_speed )
			return false;

		// Not slipping enough
		if ( GetSlipageLeft() <= slip_threshold )
			return false;

		// Not enough struct compression
		if ( m_left_compression <= compression_threshold )
			return false;

		return true;
	}

	inline bool IsSkiddingRight() const
	{
		if ( ! m_skiddable_surface )
			return false;

		// Not fast enough ground speed
		if ( m_right_wheel_ground_speed < min_ground_speed )
			return false;

		// Not slipping enough
		if ( GetSlipageRight() <= slip_threshold )
			return false;

		// Not enough struct compression
		if ( m_right_compression <= compression_threshold )
			return false;

		return true;
	}

	void SetSkiddableSurface( bool value ) { m_skiddable_surface = value; }

	inline void breakWing()
	{
		setDamageDelta( Airframe::Damage::WING_L_IN, float(random()) );
		setDamageDelta( Airframe::Damage::WING_L_CENTER, 1.0f );
		setDamageDelta( Airframe::Damage::WING_L_PART_CENTER, 1.0f );
		setDamageDelta( Airframe::Damage::FLAP_L, 1.0f );
		setDamageDelta( Airframe::Damage::WING_L_OUT, 1.0f );
		setDamageDelta( Airframe::Damage::AILERON_L, 1.0f );
	}

	double GetNoseWheelAngle() const {return m_nose_wheel_angle;}
	void SetNoseWheelForce( double x, double y, double z )
    {
	    m_nose_wheel_force.x = x;
		m_nose_wheel_force.y = y;
		m_nose_wheel_force.z = z;
    }

	void SetNoseWheelForcePosition( double x, double y, double z )
	{
		m_nose_wheel_force_position.x = x;
		m_nose_wheel_force_position.y = y;
		m_nose_wheel_force_position.z = z;
	}
private:

	void ImGuiDebugWindow();

	//Airframe Constants
	const double m_hookExtendTime = 1.5;

	//Airframe Variables
	double m_gearLPosition = 0.0; //0 -> 1
	double m_gearRPosition = 0.0;
	double m_gearNPosition = 0.0;

	double m_flapsPosition = 0.0;
	double m_spoilerPosition = 0.0;
	double m_speedBrakePosition = 0.0;
	double m_hookPosition = 0.0;
	double m_slatLPosition = 0.0;
	double m_slatRPosition = 0.0;

	double m_aileronLeft = 0.0;
	double m_aileronRight = 0.0;
	double m_elevator = 0.0;
	double m_stabilizer = 0.0;
	double m_rudder = 0.0;

	double m_noseWheelAngle = 0.0;

	std::function<void( DamageObject&, double )> on_actuator_damage = []( DamageObject& object, double integrity )
	{
		if ( integrity < 1.0 )
		{
			if ( DamageProcessor::GetDamageProcessor().Random() < 0.1 )
			{
				object.SetIntegrity( 0.0 );
			}
			else
			{
				object.SetIntegrity( integrity );
			}
		}
	};

	Actuator m_actuatorElev{ DamageProcessor::MakeDamageObjectMultiple( "Elevator Actuator", {DamageCell::ELEVATOR_L, DamageCell::ELEVATOR_R, DamageCell::STABILIZATOR_L, DamageCell::STABILIZATOR_R}, on_actuator_damage ) };
	Actuator m_actuatorAilLeft{ DamageProcessor::MakeDamageObject( "Aileron Left Actuator", DamageCell::AILERON_L, on_actuator_damage ) };
	Actuator m_actuatorAilRight{ DamageProcessor::MakeDamageObject( "Aileron Right Actuator", DamageCell::AILERON_R, on_actuator_damage ) };
	Actuator m_actuatorRud{ DamageProcessor::MakeDamageObject( "Rudder Actuator", DamageCell::RUDDER, on_actuator_damage ) };


	std::function<void( DamageObject&, double )> on_gear_jam_damage = []( DamageObject& object, double integrity )
	{
		if ( integrity < 0.9 && DamageProcessor::GetDamageProcessor().Random() >= 0.5 )
		{
			LOG_DAMAGE( "%s\n", object.GetName().c_str() );
			object.SetIntegrity( 0.0 );
		}
	};

	std::function<void( DamageObject&, double )> on_gear_actuator_damage = []( DamageObject& object, double integrity )
	{
		if ( integrity < 1.0 && DamageProcessor::GetDamageProcessor().Random() <= 0.25 )
		{
			object.SetIntegrity( 0.0 );
		}
	};

	std::shared_ptr<DamageObject> m_gear_jam_left = DamageProcessor::MakeDamageObject( "Left Gear Jam", DamageCell::WING_L_IN, on_gear_jam_damage );
	std::shared_ptr<DamageObject> m_gear_jam_right = DamageProcessor::MakeDamageObject( "Right Gear Jam", DamageCell::WING_R_IN, on_gear_jam_damage );
	std::shared_ptr<DamageObject> m_gear_jam_nose = DamageProcessor::MakeDamageObject( "Nose Gear Jam", DamageCell::CABIN_BOTTOM, on_gear_jam_damage );

	std::shared_ptr<DamageObject> m_gear_actuator_left = DamageProcessor::MakeDamageObject( "Left Gear Actuator", DamageCell::WING_L_IN, on_gear_actuator_damage );
	std::shared_ptr<DamageObject> m_gear_actuator_right = DamageProcessor::MakeDamageObject( "Right Gear Actuator", DamageCell::WING_R_IN, on_gear_actuator_damage );
	std::shared_ptr<DamageObject> m_gear_actuator_nose = DamageProcessor::MakeDamageObject( "Nose Gear Actuator", DamageCell::CABIN_BOTTOM, on_gear_actuator_damage );

	double m_elevatorZeroForceDeflection = 0.0;

	double m_left_wheel_arg = 0.0;
	double m_right_wheel_arg = 0.0;

	double m_left_wheel_arg_prev = 0.0;
	double m_right_wheel_arg_prev = 0.0;

	double m_left_wheel_speed = 0.0;
	double m_right_wheel_speed = 0.0;

	double m_left_wheel_ground_speed = 0.0;
	double m_right_wheel_ground_speed = 0.0;

	double m_left_compression = 0.0;
	double m_right_compression = 0.0;

	bool m_skiddable_surface = true;

	double m_nose_wheel_ground_speed = 0.0;
	static constexpr double m_nose_wheel_mass = 10.0;
	Vec3 m_nose_wheel_force = { 0.0, 0.0, 0.0 };
	Vec3 m_nose_wheel_force_position = { 0.0, 0.0, 0.0 };
	Vec3 m_pivot_position = { 2.696969, -2.271201, 0.0 };
	double m_nose_wheel_angular_velocity = 0.0;
	double m_nose_wheel_angle = 0.0;
	static constexpr double m_nose_wheel_moment_of_intertia = 0.0;
	static constexpr double m_nose_wheel_damping = 150.0;
	static constexpr double m_break_out_torque = 200.0;
	bool m_nose_wheel_fix = true;

	//Tank m_selected = Tank::INTERNAL;

	/*double m_fuel[4] = { 0.0, 0.0, 0.0, 0.0 };
	double m_fuelPrev[4] = { 0.0, 0.0, 0.0, 0.0 };
	Vec3 m_fuelPos[4] = { Vec3(), Vec3(), Vec3(), Vec3() };
	bool m_hasFuelTank[4] = { true, false, false, false };
	double m_fuelCapacity[4] = { 0.0, 0.0, 0.0, 0.0 };*/

	bool m_dumpingFuel = false;

	float* m_integrityElement;

	double m_mass = 1.0;

	CatapultState m_catapultState = OFF_CAT;
	bool m_catStateSent = false;
	bool m_slatsLocked = false;
	double m_catMoment = 0.0;
	double m_catForce = 0.0;
	double m_catMomentVelocity = 0.0;
	double m_catAngle = 0.0;
	double m_angle = 0.0;
	double m_integral = 0.0;
	double m_prevAccel = 0.0;
	double m_noseCompression = 0.0;

	Engine2& m_engine;
	Input& m_controls;
	AircraftState& m_state;
	std::vector<DamageDelta> m_damageStack;
};

double Airframe::setAileronLeft(double dt)
{
	double input = m_controls.roll() + m_controls.rollTrim();
	return m_actuatorAilLeft.inputUpdate(-input, dt);
}

double Airframe::setAileronRight( double dt )
{
	double input = m_controls.roll() + m_controls.rollTrim();
	return m_actuatorAilRight.inputUpdate( input, dt );
}

double Airframe::setElevator(double dt)
{
	double stabilizer = toDegrees(m_stabilizer);
	double bungeeTrimDeg = (stabilizer + 1.0) / (-13.25) * (-0.65306 - 7.3469) - 0.65306;
	double bungeeTrimStick = bungeeTrimDeg / 20.0; // transformation from control surface deflection to stick normalized coordinate goes here
	double speedbrakeTrim = -0.15 * m_speedBrakePosition;
	m_actuatorElev.setActuatorSpeed(clamp(1.0 - 1.2 * pow(m_state.getMach(), 3.0), 0.1, 1.0));
	//printf("factor: %lf\n", clamp(1.0 - 1.2 * pow(m_state.getMach(), 3.0), 0.1, 1.0));

	m_elevatorZeroForceDeflection = bungeeTrimStick + speedbrakeTrim;

	double input = m_controls.pitch() + m_elevatorZeroForceDeflection;
	return m_actuatorElev.inputUpdate(input, dt);
}

double Airframe::setRudder(double dt)
{
	double input = m_controls.yaw() + m_controls.yawDamper() + m_controls.yawTrim();
	return m_actuatorRud.inputUpdate(input, dt);
}

double Airframe::setStabilizer(double dt)
{
	double lin_transform = toRad((m_controls.pitchTrim() - 1.0)/(-2.0) * (-13.25) + 12.25);
	//printf("stickTrim: %lf\n", m_controls.pitchTrim());
	return lin_transform;
}

void Airframe::setFlapsPosition(double position)
{
	m_flapsPosition = position;
}

void Airframe::setGearLPosition(double position)
{
	m_gearLPosition = position;
}

void Airframe::setGearRPosition( double position )
{
	m_gearRPosition = position;
}

void Airframe::setGearNPosition( double position )
{
	m_gearNPosition = position;
}

void Airframe::setAirbrakePosition(double position)
{
	m_speedBrakePosition = position;
}

void Airframe::setAngle(double angle)
{
	m_angle = angle;
}

void Airframe::setMass(double mass)
{
	m_mass = mass;
}

void Airframe::setNoseCompression( double x )
{
	m_noseCompression = x;
}

void Airframe::setNoseWheelAngle( double angle )
{
	m_noseWheelAngle = angle;
}

void Airframe::setCatAngle( double angle )
{
	m_catAngle = angle;
}

void Airframe::setSlatsLocked( bool locked )
{
	m_slatsLocked = locked;
}

void Airframe::toggleSlatsLocked()
{
	m_slatsLocked = ! m_slatsLocked;
}

double Airframe::getNoseWheelAngle() const
{
	return m_noseWheelAngle;
}

double Airframe::getCatForce() const
{
	return m_catForce;
}

//double Airframe::getFuelPrevious( Tank tank ) const
//{
//	return m_fuelSystem.
//	//return m_fuelPrev[tank];
//}

double Airframe::getGearLPosition() const
{
	return m_gearLPosition;
}

double Airframe::getGearRPosition() const
{
	return m_gearRPosition;
}

double Airframe::getGearNPosition() const
{
	return m_gearNPosition;
}

double Airframe::getFlapsPosition() const
{
	return m_flapsPosition;
}

double Airframe::getSpoilerPosition() const
{
	return m_spoilerPosition;
}

double Airframe::getSpeedBrakePosition() const
{
	return m_speedBrakePosition;
}

double Airframe::getHookPosition() const
{
	return m_hookPosition;
}

double Airframe::getSlatLPosition() const
{
	return m_slatLPosition;
}

double Airframe::getSlatRPosition() const
{
	return m_slatRPosition;
}

double Airframe::getAileronLeft() const
{
	return m_aileronLeft;
}
double Airframe::getAileronRight() const
{
	return m_aileronRight;
}

double Airframe::getElevator() const
{
	return m_elevator;
}

double Airframe::getStabilizer() const
{
	return m_stabilizer;
}

double Airframe::getStabilizerAnim() const
{
	double stab = toDegrees(m_stabilizer);
	if (stab > 0.0)
	{
		return stab / 12.25;
	}
	else
	{
		return stab;
	}
}

double Airframe::getRudder() const
{
	return m_rudder;
}

double Airframe::getElevatorZeroForceDeflection() const
{
	return m_elevatorZeroForceDeflection;
}

double Airframe::aileronAngle()
{
	return 	m_aileronLeft > 0.0 ? c_aileronUp * m_aileronLeft : -c_aileronDown * m_aileronLeft;
}

double Airframe::elevatorAngle()
{
	return m_elevator > 0.0 ? -c_elevatorUp * m_elevator : c_elevatorDown * m_elevator;
}

double Airframe::rudderAngle()
{
	return m_rudder > 0.0 ? c_rudderRight * m_rudder : -c_rudderLeft * m_rudder;
}

void Airframe::setSlatLPosition(double position)
{
	m_slatLPosition = position;
}

void Airframe::setSlatRPosition(double position)
{
	m_slatRPosition = position;
}

void Airframe::setSpoilerPosition(double position)
{
	m_spoilerPosition = position;
}

const Airframe::CatapultState& Airframe::catapultState() const
{
	return m_catapultState;
}

Airframe::CatapultState& Airframe::catapultState()
{
	return m_catapultState;
}

const bool& Airframe::catapultStateSent() const
{
	return m_catStateSent;
}

bool& Airframe::catapultStateSent()
{
	return m_catStateSent;
}

void Airframe::setCatStateFromKey()
{
	switch (m_catapultState)
	{
	case ON_CAT_NOT_READY:
	case ON_CAT_READY:
	case ON_CAT_WAITING:
		printf("OFF_CAT\n");
		m_catapultState = OFF_CAT;
		break;
	case OFF_CAT:
		printf("ON_CAT_NOT_READY\n");
		m_catapultState = ON_CAT_NOT_READY;
		break;
	}
}

double Airframe::getDamageElement(Damage element) const
{
	return DMG_ELEM ( element );
}

double Airframe::getCatMoment() const
{
	return m_catMoment;
}

double Airframe::getMass() const
{
	return m_mass;
}

inline void Airframe::setIntegrityElement(Damage element, float integrity)
{
	m_integrityElement[(int)element] = integrity;
}

inline float Airframe::getIntegrityElement(Damage element)
{
	return m_integrityElement[(int)element];
}

void Airframe::setDamageDelta( Damage element, float delta )
{
	DamageDelta d;
	d.m_delta = delta;
	d.m_element = element;
	m_damageStack.push_back( d );
}

bool Airframe::processDamageStack( Damage& element, float& damage )
{
	if ( m_damageStack.empty() )
		return false;

	DamageDelta delta = m_damageStack.back();
	m_damageStack.pop_back();


	m_integrityElement[(int)delta.m_element] -= delta.m_delta;
	m_integrityElement[(int)delta.m_element] = clamp( m_integrityElement[(int)delta.m_element], 0.0f, 1.0f );
	
	element = delta.m_element;
	damage = delta.m_delta;//m_integrityElement[(int)delta.m_element];

	return true;
}

inline float Airframe::getLWingDamage() const
{
	return (DMG_ELEM( Damage::WING_L_IN) + DMG_ELEM( Damage::WING_L_CENTER) + DMG_ELEM( Damage::WING_L_OUT)) / 3.0f;
}

inline float Airframe::getRWingDamage() const
{
	return (DMG_ELEM( Damage::WING_R_IN) + DMG_ELEM( Damage::WING_R_CENTER) + DMG_ELEM( Damage::WING_R_OUT)) / 3.0f;
}

inline float Airframe::getAileronDamage() const
{
	return (DMG_ELEM(Damage::AILERON_L) + DMG_ELEM(Damage::AILERON_R)) / 2.0f;
}

inline float Airframe::getVertStabDamage() const
{
	return (DMG_ELEM( Damage::FIN_L_TOP ) + DMG_ELEM( Damage::FIN_L_BOTTOM )) / 2.0f;
}

inline float Airframe::getRudderDamage() const
{
	return DMG_ELEM( Damage::RUDDER );
}

inline float Airframe::getHoriStabDamage() const
{
	return (DMG_ELEM(Damage::STABILIZATOR_L) + DMG_ELEM(Damage::STABILIZATOR_R)) / 2.0f;
}

inline float Airframe::getElevatorDamage() const
{
	return (DMG_ELEM( Damage::ELEVATOR_L ) + DMG_ELEM( Damage::ELEVATOR_R )) / 2.0f;
}

inline float Airframe::getCompressorDamage() const
{
	return 1.0f - clamp(2.0f - DMG_ELEM( Damage::FUSELAGE_LEFT_SIDE ) - DMG_ELEM( Damage::FUSELAGE_RIGHT_SIDE ), 0.0f, 1.0f);
}
inline float Airframe::getTurbineDamage() const
{
	return 1.0f - clamp( 2.0f - DMG_ELEM( Damage::TAIL_LEFT_SIDE ) - DMG_ELEM( Damage::TAIL_RIGHT_SIDE ), 0.0f, 1.0f );
}

inline float Airframe::getSpoilerDamage() const
{
	return (DMG_ELEM( Damage::WING_L_PART_CENTER ) + DMG_ELEM( Damage::WING_R_PART_CENTER )) / 2.0f;
}
inline float Airframe::getSpeedbrakeDamage() const
{
	return (DMG_ELEM( Damage::AIR_BRAKE_L ) + DMG_ELEM( Damage::AIR_BRAKE_R )) / 2.0f;
}
inline float Airframe::getFlapDamage() const
{
	return (DMG_ELEM( Damage::FLAP_L ) + DMG_ELEM( Damage::FLAP_R )) / 2.0f;
}

double Airframe::getNoseCompression() const
{
	return m_noseCompression;
}

bool Airframe::getSlatsLocked() const
{
	return m_slatsLocked;
}

} // end namespace

#endif

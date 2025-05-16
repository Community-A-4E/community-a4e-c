#pragma once
#ifndef CONTROL_H
#define CONTROL_H
//=========================================================================//
//
//		FILE NAME	: Input.h
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Class for handling control inputs.
//
//================================ Includes ===============================//
#include "BaseComponent.h"
#include "Axis.h"
#include <Common/Maths.h>

//=========================================================================//

namespace Scooter
{//begin namespace

enum Control
{
	//Axis
	PITCH = 2001, //Stick pitch axis
	ROLL = 2002, //Stick roll axis
	YAW = 2003, //Pedals yaw axis
	THROTTLE = 2004, //Throttle axis
	GEAR_TOGGLE = 68, //68
	GEAR_UP = 430, //
	GEAR_DOWN = 431, //
	BRAKE = 2111,
	LEFT_BRAKE = 3162,
	RIGHT_BRAKE = 3163,
	FLAPS_INCREASE = 10001,
	FLAPS_DECREASE = 10002,
	FLAPS_DOWN = 145,
	FLAPS_UP = 146,
	FLAPS_TOGGLE = 72,
	AIRBRAKE_EXTEND = 147,
	AIRBRAKE_RETRACT = 148,
	HOOK_TOGGLE = 69,
	CONNECT_TO_CAT = 120,
	NOSEWHEEL_STEERING_ENGAGE = 3133,
	NOSEWHEEL_STEERING_DISENGAGE = 3134,
	STARTER_BUTTON = 3013,
	THROTTLE_DETEND = 3087,

	//Keyboard Stuff,
	RUDDER_LEFT_START = 201,
	RUDDER_LEFT_STOP = 202,
	RUDDER_RIGHT_START = 203,
	RUDDER_RIGHT_STOP = 204,

	ROLL_LEFT_START = 197,
	ROLL_LEFT_STOP = 198,
	ROLL_RIGHT_START = 199,
	ROLL_RIGHT_STOP = 200,

	PITCH_DOWN_START = 193,
	PITCH_DOWN_STOP = 194,
	PITCH_UP_START = 195,
	PITCH_UP_STOP = 196,

	THROTTLE_UP_START = 1032,
	THROTTLE_STOP = 1034,
	THROTTLE_DOWN_START = 1033,

	BRAKE_ALL_START = 10135,
	BRAKE_ALL_STOP = 10136,
	BRAKE_LEFT_START = 10180,
	BRAKE_LEFT_STOP = 10181,
	BRAKE_RIGHT_START = 10182,
	BRAKE_RIGHT_STOP = 10183,
	RADIO_MENU = 179, //iCommandToggleCommandMenu
	RADIO_PTT = 10179,

	//If the comms menu is changed these need to be found again.
	LOCK_SLATS_RADIO_MENU = 966,
	UNLOCK_SLATS_RADIO_MENU = 967,
};

class Input : public BaseComponent
{
public:

	Input();

	void update(bool brakeAssist);

	virtual void zeroInit()
	{
		m_pitch = 0.0;
		m_roll = 0.0;
		m_yaw = 0.0;

		m_pitchTrim = 0.0;
		m_rollTrim = 0.0;
		m_yawTrim = 0.0;

		m_yawDamper = 0.0;
		m_throttle = 0.0;
		m_brakeLeft = 0.0;
		m_brakeRight = 0.0;

		m_FFBEnabled = false;

		m_hook = false;
		m_nosewheelSteering = false;
		m_starter = false;

		m_pitchAxis.zeroInit();
		m_rollAxis.zeroInit();
		m_yawAxis.zeroInit();
		m_throttleAxis.zeroInit();
		m_leftBrakeAxis.zeroInit();
		m_rightBrakeAxis.zeroInit();
	}

	virtual void coldInit()
	{
		zeroInit();
	}

	virtual void hotInit()
	{
		zeroInit();
	}

	virtual void airborneInit()
	{
		zeroInit();
	}

	static inline double normalise(double value)
	{
		return (value + 1.0) / 2.0;
	}

	inline const double throttleNorm() const
	{
		return normalise( -m_throttleAxis.getValue() );
	}

	inline const double pitch() const
	{
		return m_pitchAxis.getValue();
	}
	inline void pitch(double value)
	{
		return m_pitchAxis.updateAxis(value);
	}

	inline const double roll() const
	{
		return m_rollAxis.getValue();
	}
	inline void roll(double value)
	{
		return m_rollAxis.updateAxis(value);
	}

	inline const double yaw() const
	{
		return m_yawAxis.getValue();
	}
	inline void yaw(double value)
	{
		return m_yawAxis.updateAxis(value);
	}
	inline const double& pitchTrim() const
	{
		return m_pitchTrim;
	}
	inline double& pitchTrim()
	{
		return m_pitchTrim;
	}

	inline const double& rollTrim() const
	{
		return m_rollTrim;
	}
	inline double& rollTrim()
	{
		return m_rollTrim;
	}

	inline const double& yawTrim() const
	{
		return m_yawTrim;
	}
	inline double& yawTrim()
	{
		return m_yawTrim;
	}
	inline const double& yawDamper() const
	{
		return m_yawDamper;
	}
	inline double& yawDamper()
	{
		return m_yawDamper;
	}
	inline const double& throttle() const
	{
		return m_throttleAxis.getValue();
	}
	inline void throttle(double value)
	{
		return m_throttleAxis.updateAxis(value);
	}
	inline const double brakeLeft() const
	{
		if ( ! m_brakeAssist )
			return m_leftBrakeAxis.getValue();

		//Fade the brake linearly based on rudder position.
		return ( 1.0 - clamp( m_yawAxis.getValue(), 0.0, 1.0 ) ) * m_leftBrakeAxis.getValue();
	}
	inline void brakeLeft(double value)
	{
		m_leftBrakeAxis.updateAxis(normalise(-value));
	}
	inline const double brakeRight() const
	{
		if ( ! m_brakeAssist )
			return m_rightBrakeAxis.getValue();

		//Fade the brake linearly based on rudder position.
		return (1.0 + clamp( m_yawAxis.getValue(), -1.0, 0.0 )) * m_rightBrakeAxis.getValue();
	}
	inline void brakeRight(double value)
	{
		m_rightBrakeAxis.updateAxis(normalise(-value));
	}

	inline void brakeLeftDirect( double value )
	{
		m_leftBrakeAxis.updateAxis( value );
	}

	inline void brakeRightDirect( double value )
	{
		m_rightBrakeAxis.updateAxis( value );
	}

	inline double getFFBPitchFactor()
	{
		return m_FFBPitchFactor;
	}
	inline double getFFBPitchAmplitude()
	{
		return m_FFBPitchAmplitude;
	}
	inline double getFFBPitchFrequency()
	{
		return m_FFBPitchFrequency;
	}
	inline double getFFBRollFactor()
	{
		return m_FFBRollFactor;
	}
	inline double getFFBRollAmplitude()
	{
		return m_FFBRollAmplitude;
	}
	inline double getFFBRollFrequency()
	{
		return m_FFBRollFrequency;
	}

	inline bool getFFBEnabled()
	{
		return m_FFBEnabled;
	}

	inline void setFFBEnabled( bool enabled )
	{
		m_FFBEnabled = enabled;
	}

	inline const bool& hook() const
	{
		return m_hook;
	}
	inline bool& hook()
	{
		return m_hook;
	}
	inline const bool& nosewheelSteering() const
	{
		return m_nosewheelSteering;
	}
	inline bool& nosewheelSteering()
	{
		return m_nosewheelSteering;
	}
	inline const bool& starter() const
	{
		return m_starter;
	}
	inline bool& starter()
	{
		return m_starter;
	}

	inline Axis& pitchAxis()
	{
		return m_pitchAxis;
	}

	inline Axis& rollAxis()
	{
		return m_rollAxis;
	}

	inline Axis& yawAxis()
	{
		return m_yawAxis;
	}

	inline Axis& throttleAxis()
	{
		return m_throttleAxis;
	}

	inline Axis& leftBrakeAxis()
	{
		return m_leftBrakeAxis;
	}

	inline Axis& rightBrakeAxis()
	{
		return m_rightBrakeAxis;
	}

	inline Axis& mouseXAxis()
	{
		return m_mouseX;
	}

	inline Axis& mouseYAxis()
	{
		return m_mouseY;
	}

private:

	Axis m_pitchAxis;
	Axis m_rollAxis;
	Axis m_yawAxis;
	Axis m_throttleAxis;
	Axis m_leftBrakeAxis;
	Axis m_rightBrakeAxis;
	Axis m_mouseX;
	Axis m_mouseY;

	double m_pitch = 0.0;
	double m_roll = 0.0;
	double m_yaw = 0.0;

	double m_pitchTrim = 0.0;
	double m_rollTrim = 0.0;
	double m_yawTrim = 0.0;

	double m_yawDamper = 0.0;
	double m_throttle = 0.0;
	double m_brakeLeft = 0.0;
	double m_brakeRight = 0.0;

	double m_FFBPitchFactor = 1.0;
	double m_FFBPitchAmplitude = 0.0;
	double m_FFBPitchFrequency = 0.0;
	double m_FFBRollFactor = 1.0;
	double m_FFBRollAmplitude = 0.0;
	double m_FFBRollFrequency = 0.0;
	bool m_FFBEnabled = false;


	bool m_hook = false;
	bool m_nosewheelSteering = false;
	bool m_starter = false;
	bool m_brakeAssist = false;
};

}//end namespace

#endif
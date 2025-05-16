//=========================================================================//
//
//		FILE NAME	: Actuator.cpp
//		AUTHOR		: TerjeTL
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Actuator class to provide realistic movement for the
//						controls.
//
//================================ Includes ===============================//
#include "Actuator.h"
#include <Common/Maths.h>
#include <cmath>
//=========================================================================//

namespace Scooter
{ // start namespace

Actuator::Actuator( std::shared_ptr<DamageObject> damage ) : m_damage(damage), m_actuatorSpeed{ 10.0 }, m_actuatorPos{ 0.0 }, m_actuatorTargetPos{ 0.0 }, m_actuatorFactor{ 1.0 }
{

}

Actuator::Actuator( std::shared_ptr<DamageObject> damage, double speed) : m_damage( damage ), m_actuatorSpeed{ speed }, m_actuatorPos{ 0.0 }, m_actuatorTargetPos{ 0.0 }, m_actuatorFactor{ 1.0 }
{

}

Actuator::~Actuator()
{

}

void Actuator::zeroInit()
{

}
void Actuator::coldInit()
{

}
void Actuator::hotInit()
{

}
void Actuator::airborneInit()
{

}

double Actuator::inputUpdate(double targetPosition, double dt)
{
	m_actuatorTargetPos = targetPosition;

	physicsUpdate(dt);

	return m_actuatorPos;
}

void Actuator::physicsUpdate(double dt)
{
	double speedToTarget = (m_actuatorTargetPos - m_actuatorPos)/dt;
	
	
	double actuatorSpeed = 0.0;

	// logic for control speed dependant on aerodynamic load. Down the line this will be better handled in a separate pilot physiology class
	if (m_actuatorPos > 0.0)
	{
		if (m_actuatorTargetPos - m_actuatorPos < 0.0)
		{
			actuatorSpeed = m_actuatorSpeed;
		}
		else
		{
			actuatorSpeed = m_actuatorSpeed * m_actuatorFactor;
		}
	}
	else
	{
		if (m_actuatorTargetPos - m_actuatorPos > 0.0)
		{
			actuatorSpeed = m_actuatorSpeed;
		}
		else
		{
			actuatorSpeed = m_actuatorSpeed * m_actuatorFactor;
		}
	}

	actuatorSpeed *= m_damage->GetIntegrity();

	if (abs(speedToTarget) <= actuatorSpeed)
	{
		m_actuatorPos = m_actuatorTargetPos;
	}
	else
	{
		m_actuatorPos += copysign(1.0, speedToTarget) * actuatorSpeed * dt;
	}

	m_actuatorPos = clamp( m_actuatorPos, -1.0, 1.0 );
}

double Actuator::getPosition()
{
	return m_actuatorPos;
}

void Actuator::setActuatorSpeed(double factor)
{
	m_actuatorFactor = factor;
}

} // end namespace






























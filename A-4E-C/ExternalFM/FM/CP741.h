#pragma once
#ifndef CP741_H
#define CP741_H
//=========================================================================//
//
//		FILE NAME	: CP741.h
//		AUTHOR		: Joshua Nelson
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	CP-741/A bombing computer class. Calculates bomb travel
//						distance using the current aircraft state vector.
//						This just solves the equation for a parabola, so no
//						air resistance is taken into account.
//
//================================ Includes ===============================//
#include "BaseComponent.h"
#include "AircraftState.h"
#include "MovingAverage.h"
#include <Common/Vec3.h>
//=========================================================================//

namespace Scooter
{

class CP741 : public BaseComponent
{
public:
	CP741( AircraftState& state );

	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();

	inline void setPower( bool power );
	inline void setEjectionVelocity( double ejectionVelocity ) { m_ejectionVelocity = ejectionVelocity; }

	void updateSolution();
	void setTarget( bool set, double slant );
	inline void setGunsightAngle( double angle );

	inline bool getSolution();
	inline bool getTargetSet();

	double calculateHorizontalDistance();
	double calculateImpactDistance( double angle ) const;
	double calculateImpactDistanceDragless( double angle ) const;
	bool inRange();

private:

	AircraftState& m_state;
	bool m_power = false;
	bool m_solution = false;
	bool m_targetSet = false;
	bool m_targetFound = false;
	double m_gunsightAngle = 0.0;
	double m_ejectionVelocity = 3.0;
	Vec3 m_target;
	MovingAverage<double, 30> m_slant;
};

void CP741::setPower( bool power )
{
	m_power = power;
}

void CP741::setGunsightAngle( double angle )
{
	m_gunsightAngle = angle;
}

bool CP741::getSolution()
{
	return m_solution;
}

bool CP741::getTargetSet()
{
	return m_targetSet;
}

}

#endif //CP741_H
#pragma once
//=========================================================================//
//
//		FILE NAME	: AeroElement.cpp
//		AUTHOR		: TerjeTL
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Provides element classes for aerodynamics simulation.
//
//================================ Includes ===============================//
#include "AeroElement.h"
#include "Units.h"
//================================ Includes ===============================//

Scooter::AeroElement::AeroElement
(
	AircraftState& state,
	Type type,
	Table& CLalpha,
	Table& CDalpha,
	Vec3 cp,
	Vec3 surfaceNormal,
	double area
) :
	m_state{ state },
	m_type{ type },
	m_CLalpha{ CLalpha },
	m_CDalpha{ CDalpha },
	m_cp{ cp },
	m_surfaceNormal{ surfaceNormal },
	m_area{ area },
	m_dragFactor{ 1.0 },
	m_liftFactor{ 1.0 },
	m_aoaModifier{ false }
{

}

Scooter::AeroControlElement::AeroControlElement
(
	AircraftState& state,
	Airframe& airframe,
	Type controlSurfaceType,
	Table& CLalpha,
	Table& CDalpha,
	Table* compressibility,
	Vec3 cp,
	Vec3 surfaceNormal,
	double area
) :
	AeroElement(state, controlSurfaceType, CLalpha, CDalpha, cp, surfaceNormal, area), m_airframe{ airframe }, m_compressElev{ compressibility }
{
	m_aoaModifier = true;
}

Scooter::AeroControlElement::AeroControlElement
(
	AircraftState& state,
	Airframe& airframe,
	Type controlSurfaceType,
	Table& CLalpha,
	Table& CDalpha,
	Vec3 cp,
	Vec3 surfaceNormal,
	double area
) :
	AeroElement(state, controlSurfaceType, CLalpha, CDalpha, cp, surfaceNormal, area ), m_airframe{ airframe }, m_compressElev{ nullptr }
{
	m_aoaModifier = true;
}

void Scooter::AeroElement::zeroInit()
{
	m_dragFactor = 1.0;
	m_liftFactor = 1.0;
	m_scalarAirspeed = 0.0;
	m_aoa = 0.0;
	m_beta = 0.0;
	m_kElem = 0.0;
	m_damageElem = 1.0f;
	m_airspeed = Vec3();
	m_liftVec = Vec3();
	m_dragVec = Vec3();
	m_LDwindAxes = Vec3();
	m_RForceElement = Vec3();
	m_moment = Vec3();
}

void Scooter::AeroElement::coldInit()
{
	zeroInit();
}

void Scooter::AeroElement::hotInit()
{
	zeroInit();
}

void Scooter::AeroElement::airborneInit()
{
	zeroInit();
}

void Scooter::AeroElement::elementLift()
{
	if (m_type == HORIZONTAL || m_type == AILERON || m_type == ELEVATOR || m_type == HORIZONTAL_STAB )
	{
		m_LDwindAxes.y = m_kElem * (m_CLalpha(m_aoa) * (cos(m_beta)) * m_liftFactor * m_damageElem);
	}
	else if (m_type == VERTICAL || m_type == RUDDER)
	{
		m_LDwindAxes.z = m_kElem * (m_CLalpha(m_aoa) * (cos(m_beta)) * m_liftFactor * m_damageElem);
	}
	else
	{
		printf("ERROR: could not calculate lift: %d\n", m_type);
	}
}

void Scooter::AeroElement::elementDrag()
{
	double cosBeta = cos( m_beta );
	/*if ( m_type != RUDDER )
		cosBeta = abs( cosBeta );*/

	m_LDwindAxes.x = -m_kElem * ( m_CDalpha( m_aoa ) * cosBeta * m_dragFactor );
}

void Scooter::AeroElement::calculateElementPhysics()
{
	//reset variables before calculations..
	m_LDwindAxes.x = 0.0;
	m_LDwindAxes.y = 0.0;
	m_LDwindAxes.z = 0.0;
	
	// calculate member variables
	m_airspeed = m_state.getLocalAirspeed() + cross(m_state.getOmega(), m_cp);
	m_scalarAirspeed = sqrt(m_airspeed * m_airspeed);
	m_dragVec = -normalize(m_airspeed);
	m_kElem = pow(m_scalarAirspeed, 2) * m_state.getAirDensity() * m_area * 0.5;
	
	//calculate aoa and beta
	Vec3 forwardVec(1.0, 0.0, 0.0);
	Vec3 spanVec = normalize(cross(m_surfaceNormal, forwardVec));
	Vec3 flightPath = m_airspeed;
	Vec3 flightPathProjectedAOA = flightPath - ((flightPath * spanVec) / (spanVec * spanVec)) * spanVec;
	Vec3 flightPathProjectedBeta = flightPath - ((flightPath * m_surfaceNormal) / (m_surfaceNormal * m_surfaceNormal)) * m_surfaceNormal;

	m_aoa = atan2( cross( forwardVec, flightPathProjectedAOA ) * spanVec, forwardVec * flightPathProjectedAOA );
	

	if ( m_type == RUDDER || m_type == ELEVATOR || m_type == HORIZONTAL_STAB )
		m_beta = 0.0;
	else
		m_beta = atan2( cross( forwardVec, flightPathProjectedBeta ) * m_surfaceNormal, forwardVec * flightPathProjectedBeta );

	
	if (m_aoaModifier) // if the element has control surfaces
	{
		m_aoa += controlInput();
	}

	elementLift();
	elementDrag();

	updateLERX();
	
	
	if (m_type == HORIZONTAL || m_type == AILERON || m_type == ELEVATOR || m_type == HORIZONTAL_STAB )
	{
		m_RForceElement = windAxisToBody( m_LDwindAxes, m_aoa, m_beta );
		//printf( "alpha: %lf, beta: %lf, lift vector (w): LDVec = %lf, %lf, %lf, Body: %lf, %lf, %lf\n", m_aoa, m_beta, m_LDwindAxes.x, m_LDwindAxes.y, m_LDwindAxes.z, m_RForceElement.x, m_RForceElement.y, m_RForceElement.z );	
	}
	else if (m_type == VERTICAL || m_type == RUDDER)
	{
		m_RForceElement = windAxisToBody(m_LDwindAxes, m_beta, m_aoa);
		//printf( "alpha: %lf, beta: %lf, lift vector (w): LDVec = %lf, %lf, %lf, Body: %lf, %lf, %lf\n", m_aoa, m_beta, m_LDwindAxes.x, m_LDwindAxes.y, m_LDwindAxes.z, m_RForceElement.x, m_RForceElement.y, m_RForceElement.z );
		//printf( "CD(aoa): %lf\n", m_CDalpha( m_aoa ) );
	}
	else
	{
		printf("ERROR: could not calculate resultant force");
	}

	Vec3 deltaCentreOfPressure = m_cp - m_state.getCOM(); //-Vec3(0.0, 0.0, m_state.getCOM().z); 
	//Vec3 deltaCentreOfPressure = m_cp - Vec3(0.0, 0.0, m_state.getCOM().z); 
	m_moment = cross( deltaCentreOfPressure, m_RForceElement);
}

double Scooter::AeroControlElement::controlInput()
{
	switch (m_type) // might be cleaner to call a function in each case
	{
	case HORIZONTAL_STAB:
	{
		double hStabIncidence = -m_airframe.getStabilizer() * 1.5 + m_airframe.elevatorAngle() * 1.3;// * 1.0 * ( *m_compressElev )( m_state.getMach() );
		return hStabIncidence;
	}
	case ELEVATOR:
	{
		double elevator = m_airframe.elevatorAngle();//* ( *m_compressElev )( m_state.getMach() );
		double hStabIncidence = -m_airframe.getStabilizer();
		return hStabIncidence + elevator;
	}
	case RUDDER:
		return -m_airframe.getRudder() * toRad(17);
	case AILERON:
		if (m_cp.z > 0)
		{
			return -m_airframe.getAileronRight() * toRad(14);
		}
		else
		{
			return -m_airframe.getAileronLeft() * toRad(14);
		}
	default:
		printf("ERROR: invalid control surface\n");
		break;
	}

	return 0.0;
}
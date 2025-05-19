#pragma once
#ifndef AIRCRAFT_MOTION_STATE_H
#define AIRCRAFT_MOTION_STATE_H
//=========================================================================//
//
//		FILE NAME	: AircraftState.h
//		AUTHOR		: Joshua Nelson
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	State class contains the current state for the aircraft
//						to make accessing certain parameters much easier from
//						different locations.
//
//================================ Includes ===============================//
#include "BaseComponent.h"
#include <math.h>
#include <Common/Maths.h>
//=========================================================================//

namespace Scooter
{

class AircraftState : public BaseComponent
{
public:
	AircraftState();
	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();

	struct Quat 
	{
		double w;
		double x;
		double y;
		double z;
	};

	inline void setCurrentStateBodyAxis(double aoa, double beta, const Vec3& angle, const Vec3& omega, const Vec3& omegaDot, const Vec3& speed, const Vec3& airspeed, const Vec3& acceleration);
	inline void setCurrentStateWorldAxis( const Vec3& worldPosition, const Vec3& worldVelocity, const Vec3& worldDirection, const Vec3& worldUp, const Vec3& globalDown );
	void SetWorldQuaternion( double w, double x, double y, double z )
	{
		world_orientation.w = w;
		world_orientation.x = x;
		world_orientation.y = y;
		world_orientation.z = z;
	}
	inline void setCurrentAtmosphere( double temperature, double speedOfSound, double density, double pressure, const Vec3& wind );
	inline void setSurface( double surfaceHeight, const Vec3& surfaceNormal );

	inline void setMach( double mach );
	inline void setRadarAltitude( double altitude );
	inline void setCOM( const Vec3& com );
	inline void setGForce( const double gs );

	inline const Vec3& getWorldPosition() const;
	inline const Vec3& getWorldVelocity() const;
	inline const Vec3& getWorldDirection() const;
	const Vec3& getWorldUp() const { return m_worldUp; }
	const Vec3& getWorldRight() const { return m_worldRight; }
	inline const Vec3& getWorldWind() const;
	inline const Vec3& getAngle() const;
	inline const Vec3& getOmega() const;
	inline const Vec3& getOmegaDot() const;
	inline const Vec3& getLocalSpeed() const;
	inline const Vec3& getLocalAirspeed() const;
	inline const Vec3& getLocalAcceleration() const;

	Quat GetOrientation() { return world_orientation; }

	inline const Vec3& getWorldWindVelocity() const;
	inline const double getPressure() const;
	inline const double getSpeedOfSound() const;
	inline const double getTemperature() const;
	inline const double getAirDensity() const;

	inline const double getAOA() const;
	inline const double getBeta() const;
	inline const double getMach() const;
	inline const double getMeasuredMach() const;
	inline const double getRadarAltitude() const;

	inline const Vec3& getCOM() const;

	//This comes from lua, if you need faster updating g-force
	//Then calculate it from the global acceleration values.
	inline const double getGForce() const;

	inline const Vec3& getGlobalDownVectorInBody() const;

	inline const Vec3& getSurfaceNormal() const;
	inline const double getSurfaceHeight() const;


private:
	Vec3 m_worldPosition;
	Vec3 m_worldVelocity;
	Vec3 m_worldDirection;
	Vec3 m_worldUp;
	Vec3 m_worldRight;
	Vec3 m_worldWind;
	Vec3 m_angle;
	Vec3 m_omega;
	Vec3 m_omegaDot;
	Vec3 m_localSpeed;
	Vec3 m_localAirspeed;
	Vec3 m_localAcceleration;
	Vec3 m_com; //centre of mass
	Vec3 m_globalDownInLocal;
	Vec3 m_surfaceNormal;

	Quat world_orientation;

	double m_aoa;
	double m_beta;
	double m_mach;
	double m_speedOfSound;
	double m_airDensity;
	double m_temperature;
	double m_pressure;
	double m_radarAltitude;
	double m_gs;
	double m_surfaceHeight;
};

	
void AircraftState::setCurrentStateBodyAxis( 
	double aoa, 
	double beta, 
	const Vec3& angle, 
	const Vec3& omega, 
	const Vec3& omegaDot,
	const Vec3& localSpeed,
	const Vec3& airspeed, 
	const Vec3& acceleration 
)
{
	m_aoa = aoa;
	m_beta = beta;
	m_angle = angle;
	m_omega = omega;
	m_omegaDot = omegaDot;
	m_localSpeed = localSpeed;
	m_localAirspeed = airspeed;
	m_localAcceleration = acceleration;
}

void AircraftState::setCurrentStateWorldAxis( 
	const Vec3& worldPosition,
	const Vec3& worldVelocity,
	const Vec3& worldDirection,
	const Vec3& worldUp,
	const Vec3& globalDown
)
{
	m_worldPosition = worldPosition;
	m_worldVelocity = worldVelocity;
	m_worldDirection = worldDirection;
	m_worldUp = worldUp;
	m_worldRight = cross(worldDirection, worldUp);
	m_globalDownInLocal = globalDown;

}

void AircraftState::setCurrentAtmosphere( 
	double temperature, 
	double speedOfSound, 
	double density, 
	double pressure, 
	const Vec3& wind 
)
{
	m_temperature = temperature;
	m_speedOfSound = speedOfSound;
	m_airDensity = density;
	m_pressure = pressure;
	m_worldWind = wind;
}

void AircraftState::setSurface( double surfaceHeight, const Vec3& surfaceNormal )
{
	m_surfaceHeight = surfaceHeight;
	m_surfaceNormal = surfaceNormal;
}

void AircraftState::setMach( double mach )
{
	m_mach = mach;
}

void AircraftState::setCOM( const Vec3& com )
{
	m_com = com;
}

void AircraftState::setGForce( const double gs )
{
	m_gs = gs;
}

const Vec3& AircraftState::getWorldWindVelocity() const
{
	return m_worldWind;
}

const double AircraftState::getPressure() const
{
	return m_pressure;
}

const double AircraftState::getSpeedOfSound() const
{
	return m_speedOfSound;
}
const double AircraftState::getTemperature() const
{
	return m_temperature;
}

void AircraftState::setRadarAltitude( double altitude )
{
	m_radarAltitude = altitude;
}

const double AircraftState::getMach() const
{
	return m_mach;
}

const double AircraftState::getMeasuredMach() const
{
	double lowMachFactor = clamp(pow(m_mach / 0.12, 3.0), 0.0, 1.0);

	return m_mach * lowMachFactor;
}

const double AircraftState::getAirDensity() const
{
	return m_airDensity;
}

const Vec3& AircraftState::getWorldPosition() const
{
	return m_worldPosition;
}

const Vec3& AircraftState::getWorldVelocity() const
{
	return m_worldVelocity;
}

const Vec3& AircraftState::getWorldDirection() const
{
	return m_worldDirection;
}

const Vec3& AircraftState::getWorldWind() const
{
	return m_worldWind;
}

const Vec3& AircraftState::getAngle() const
{
	return m_angle;
}

const Vec3& AircraftState::getOmega() const
{
	return m_omega;
}

const Vec3& AircraftState::getOmegaDot() const
{
	return m_omegaDot;
}

const Vec3& AircraftState::getLocalSpeed() const
{
	return m_localSpeed;
}

const Vec3& AircraftState::getLocalAirspeed() const
{
	return m_localAirspeed;
}

const Vec3& AircraftState::getLocalAcceleration() const
{
	return m_localAcceleration;
}

const double AircraftState::getAOA() const
{
	return m_aoa;
}

const double AircraftState::getBeta() const
{
	return m_beta;
}

const double AircraftState::getRadarAltitude() const
{
	return m_radarAltitude;
}

const Vec3& AircraftState::getCOM() const
{
	return m_com;
}

const double AircraftState::getGForce() const
{
	return m_gs;
}

const Vec3& AircraftState::getGlobalDownVectorInBody() const
{
	return m_globalDownInLocal;
}

const Vec3& AircraftState::getSurfaceNormal() const
{
	return m_surfaceNormal;
}

const double AircraftState::getSurfaceHeight() const
{
	return m_surfaceHeight;
}

}




#endif
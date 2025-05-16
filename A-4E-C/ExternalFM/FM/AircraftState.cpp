//=========================================================================//
//
//		FILE NAME	: AircraftState.cpp
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
#include "AircraftState.h"
//=========================================================================//

Scooter::AircraftState::AircraftState()
{
	zeroInit();
}

//Seriously need to set EVERY VARIABLE to zero (or approriate value if zero causes singularity) in the constructor and 
//in this function. Otherwise Track's become unusable because of the butterfly effect.
void Scooter::AircraftState::zeroInit()
{
	m_worldPosition = Vec3();
	m_worldVelocity = Vec3();
	m_worldDirection = Vec3();
	m_worldWind = Vec3();
	m_angle = Vec3();
	m_omega = Vec3();
	m_omegaDot = Vec3();
	m_localSpeed = Vec3();
	m_localAirspeed = Vec3();
	m_localAcceleration = Vec3();
	m_com = Vec3();
	m_globalDownInLocal = Vec3();
	m_surfaceNormal = Vec3();

	m_aoa = 0.0;
	m_beta = 0.0;
	m_mach = 0.0;
	m_airDensity = 0.0;
	m_pressure = 0.0;
	m_temperature = 0.0;
	m_speedOfSound = 0.0;
	m_radarAltitude = 0.0;
	m_gs = 0.0;
	m_surfaceHeight = 0.0;

	world_orientation.w = 1.0;
	world_orientation.x = 0.0;
	world_orientation.y = 0.0;
	world_orientation.z = 0.0;

}

void Scooter::AircraftState::coldInit()
{
	zeroInit();
}

void Scooter::AircraftState::hotInit()
{
	zeroInit();
}

void Scooter::AircraftState::airborneInit()
{
	zeroInit();
}
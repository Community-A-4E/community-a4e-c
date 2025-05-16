#pragma once
//=========================================================================//
//
//		FILE NAME	: Ship.h
//		AUTHOR		: Joshua Nelson
//		DATE		: October 2021
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Ship object for radar.
//
//================================ Includes ===============================//
#include <Common/Vec3.h>
#include <stdint.h>

constexpr static double c_radarGain = 2.0e0;

struct Ship
{
	uint32_t id;
	double rcs;
	Vec3 pos;
	double heading;
};
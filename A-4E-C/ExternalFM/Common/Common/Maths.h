#pragma once
//=========================================================================//
//
//		FILE NAME	: Maths.h
//		AUTHOR		: TerjeTL
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Utility maths functions.
//
//================================ Includes ===============================//
#include <math.h>
#include <Common/Vec3.h>
#include <algorithm>
//=========================================================================//

//To stop silly macros.
#undef max
#undef min


#define PI 3.14159265359

namespace Scooter
{

extern const Vec3 rotate( const Vec3& v, const double pitch, const double yaw );
extern const Vec3 rotateVectorIntoXYPlane( const Vec3& v );
extern const Vec3 windAxisToBody(const Vec3& force, const double& alpha, const double& beta);
extern const Vec3 directionVector( const double pitch, const double yaw );

}

static inline double toDegrees( double radians )
{
	return radians * 180.0 / PI;
}

static inline double toRad(double degrees)
{
	return degrees * PI / 180.0;
}

template<std::floating_point T>
static inline T clamp( T value, T min, T max )
{
	return std::max( std::min( value, max ), min );
}

//Weight goes from 0 -> 1
static inline double lerpWeight( double v0, double v1, double w )
{
	return v0 + w * (v1 - v0);
}

static inline double random()
{
	return (double)(rand() % 100) / 100.0;
}

static inline double randomCentred()
{
	return 2.0 * random() - 1.0;
}
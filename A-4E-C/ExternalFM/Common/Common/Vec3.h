#pragma once
#ifndef VEC3_H
#define VEC3_H
//=========================================================================//
//
//		FILE NAME	: Vec3.h
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Vec3 class with added operator overloads to make maths easier.
//
//================================ Includes ===============================//
//=========================================================================//
#include <math.h>
struct Vec3
{
	Vec3() : x(0.0), y(0.0), z(0.0) {}
	Vec3(double x_, double y_, double z_) :x(x_), y(y_), z(z_) {}
	Vec3(double v) : x(v), y(v), z(v) {}
	double x;
	double y;
	double z;

	//Overloaded Operators for ED's silly vector struct.
	Vec3 operator -() const
	{
		Vec3 result;
		result.x = -this->x;
		result.y = -this->y;
		result.z = -this->z;
		return result;
	}

	Vec3& operator+= (const Vec3& v)

	{
		this->x += v.x;
		this->y += v.y;
		this->z += v.z;
		return *this;
	}

	Vec3& operator-= (const Vec3& v)

	{
		this->x -= v.x;
		this->y -= v.y;
		this->z -= v.z;
		return *this;
	}

	Vec3& operator*= (const double& s)

	{
		this->x *= s;
		this->y *= s;
		this->z *= s;
		return *this;
	}

	Vec3& operator/= (const double& s)

	{
		this->x /= s;
		this->y /= s;
		this->z /= s;
		return *this;
	}

	Vec3 operator+ (const Vec3& v) const

	{
		Vec3 result;
		result.x = this->x + v.x;
		result.y = this->y + v.y;
		result.z = this->z + v.z;
		return result;
	}

	Vec3 operator- (const Vec3& v) const

	{
		Vec3 result;
		result.x = this->x - v.x;
		result.y = this->y - v.y;
		result.z = this->z - v.z;
		return result;
	}

	Vec3 operator/ (const double& s) const

	{
		Vec3 result;
		result.x = this->x / s;
		result.y = this->y / s;
		result.z = this->z / s;
		return result;
	}

	double operator* (const Vec3& v) const

	{
		double result;
		result = this->x * v.x + this->y * v.y + this->z * v.z;
		return result;
	}
};

//Overloaded Operators for ED's silly vector struct.
inline Vec3 operator* (const double& s, const Vec3& v)

{
	Vec3 result;
	result.x = v.x * s;
	result.y = v.y * s;
	result.z = v.z * s;
	return result;
}

inline Vec3 operator* (const Vec3& v, const double& s)

{
	Vec3 result;
	result.x = v.x * s;
	result.y = v.y * s;
	result.z = v.z * s;
	return result;
}

//inline Vec3 operator* (const Vec3& v1, const Vec3& v2)
//{
//	double res = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
//	return res;
//}

inline Vec3 cross(const Vec3& a, const Vec3& b)
{
	return Vec3(a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x);
}

inline Vec3 normalize(const Vec3& a)
{
	double scalar{ sqrt(a.x * a.x + a.y * a.y + a.z * a.z) };
	Vec3 result;
	result.x = a.x / scalar;
	result.y = a.y / scalar;
	result.z = a.z / scalar;
	return result;
}

inline double dot( const Vec3& a, const Vec3& b )
{
	return a.x * b.x + a.y * b.y + a.z * b.z;
}

inline double magnitude( const Vec3& a )
{
	return sqrt(dot( a, a ));
}

inline double magnitudeSquared( const Vec3& a )
{
	return dot( a, a );
}

struct Vec3f
{
	Vec3f() {}
	Vec3f( const Vec3& v ) :
		x( float(v.x) ), y( float( v.y) ), z( float( v.z ) )
	{}

	float x = 0.0;
	float y = 0.0;
	float z = 0.0;
};

#endif


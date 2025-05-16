#pragma once
//=========================================================================//
//
//		FILE NAME	: Units.h
//		AUTHOR		: Joshua Nelson
//		DATE		: June 2021
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Unit conversion literals.
//
//================================ Includes ===============================//

constexpr inline long double operator"" _deg( long double x )
{
	return x * 0.01745329252;
}

constexpr inline long double operator"" _nauticalMile( long double x )
{
	return x * 1852.0;
}

inline long double operator"" _yard( long double x )
{
	return x * 0.9144;
}

constexpr inline long double operator"" _feet( long double x )
{
	return x * 0.3048;
}

constexpr inline long double operator"" _mil( long double x )
{
	return x * 0.00098175;
}

constexpr long double operator"" _hours(long double x)
{
	return 3600.0 * x;
}

// RPM -> rad/s
constexpr long double operator"" _rpm( long double x )
{
	return x * 0.1047197551;
}
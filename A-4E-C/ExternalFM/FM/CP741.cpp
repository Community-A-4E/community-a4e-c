//=========================================================================//
//
//		FILE NAME	: CP741.cpp
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
#include "CP741.h"
#include <stdio.h>
#include <math.h>
#include <Common/Maths.h>
#include "Units.h"
#include "AirframeConstants.h"
//=========================================================================//

//             angle from weapons dataum + fudge factor
//#define c_weaponDatum (3.0_deg +  10.0_mil) //(0.05235987756)// + 0.01)
#define PULL_UP_ANGLE 0.785398

Scooter::CP741::CP741( AircraftState& state ):
	m_state(state)
{
	
}

void Scooter::CP741::zeroInit()
{
	m_solution = false;
	m_power = false;
	m_targetSet = false;
	m_target = Vec3();
	m_gunsightAngle = 0.0;
	m_slant.setAll( 1000.0 );
}

void Scooter::CP741::coldInit()
{

}

void Scooter::CP741::hotInit()
{

}

void Scooter::CP741::airborneInit()
{

}

void Scooter::CP741::updateSolution()
{
	//Must be turned on
	if ( ! m_power )
		return;

	//Target must be set otherwise we can't range to anything.
	if ( ! m_targetSet )
		return;

	//We already have a solution
	if ( m_solution )
		return;

	//Target must be below us.
	if ( m_target.y > m_state.getWorldPosition().y )
		return;

	double horizontalDistance = calculateHorizontalDistance();
	double impactDistance = calculateImpactDistanceDragless( 0.0 );//calculateImpactDistance( 0.0 );
	//double impactDistanceDragless = calculateImpactDistanceDragless( 0.0 );

	//printf( "Drag Error: %lf\n", impactDistanceDragless - impactDistance);

	double error = fabs( horizontalDistance - impactDistance );

	//printf( "Distance: %lf, Bomb Flight Distance: %lf\n", horizontalDistance, impactDistance );

	if ( error < 5.0 )
	{
		m_solution = true;
		//printf( "Bomb away!\n" );
	}
}

double Scooter::CP741::calculateHorizontalDistance()
{
	Vec3 distance = m_target - m_state.getWorldPosition();
	distance.y = 0.0;
	Vec3 velocity = m_state.getWorldVelocity();
	velocity.y = 0.0;

	double sign = distance * velocity > 0.0 ? 1.0 : -1.0;
	//Horizontal component
	return sign*magnitude( distance );
}

void Scooter::CP741::setTarget( bool set, double slant )
{
	if ( ! m_power )
	{
		m_solution = false;
		m_targetSet = false;
		m_targetFound = false;
		return;
	}

	//Pitch - weapon datum
	double weaponAngle = m_state.getAngle().z + c_weaponsDatum;// - m_gunsightAngle;

	//If there is no radar data and we are not going to create a singularity
	//then use the radar altimiter.
	if ( slant <= 10.0 && weaponAngle != 0.0 )
	{
		if ( weaponAngle < 0.0 )
		{
			slant = m_state.getRadarAltitude() / fabs(sin( weaponAngle ));
		}
	}

	//If the target is already set we do not want to set it again.
	if ( m_targetSet )
	{
		//If the target is set and the command is to unset then
		//we need to unset the target and reset solution.
		if ( ! set )
		{
			m_targetSet = false;
			m_solution = false;
			m_targetFound = false;
		}
	}
	else if ( slant > 10.0)
	{
		m_slant.add( slant );

		//Reset solution.
		m_solution = false;
		m_targetFound = true;

		//Set target to what was passed. We need to continually update the position
		//tracked by the radar, this is to give a valid inrange light.
		m_targetSet = set;
		//printf( "CP741 Slant: %lf\n", m_slant.value() );
		
		//printf( "Angle: %lf, Range: %lf\n", weaponAngle, slant );
		Vec3 direction = directionVector( weaponAngle, m_state.getAngle().y );
		m_target = direction * m_slant.value() + m_state.getWorldPosition();
		//printf( "Target: %lf,%lf,%lf\n", m_target.x, m_target.y, m_target.z );
	}
	else
	{
		m_targetFound = false;
	}
}

double Scooter::CP741::calculateImpactDistanceDragless( double angle ) const
{
	Vec3 velocity = rotateVectorIntoXYPlane(m_state.getWorldVelocity());

	if ( angle != 0.0 )
	{
		velocity = rotate( velocity, angle, 0.0 );
	}

	Vec3 normal( 0.0, 0.0, 1.0 );
	Vec3 ejectionVelocity = m_ejectionVelocity * cross( normalize( velocity ), normal );
	//printf( "Ejection Velocity: %lf, %lf\n", ejectionVelocity.x, ejectionVelocity.y );

	velocity += ejectionVelocity;

	//Calculate time until impact.
	double ua = velocity.y / (-9.81);
	double h = m_target.y - m_state.getWorldPosition().y;
	double t = -ua + sqrt( ua * ua + (2.0*h) / (-9.81) );

	//Get horizontal component distance.
	double distHoriz = velocity.x * t;
	return distHoriz;
}

constexpr double c_CD = 0.0; // 0.15;//0.26;
constexpr double c_mass = 228;
constexpr double c_caliber = 0.273;
constexpr double c_area = PI * (c_caliber/2.0)*( c_caliber / 2.0 );

constexpr double c_coeff = c_CD * c_area * 0.5 / c_mass;


double Scooter::CP741::calculateImpactDistance( double angle ) const
{
	Vec3 velocity = rotateVectorIntoXYPlane( m_state.getWorldVelocity() );

	if ( angle != 0.0 )
	{
		velocity = rotate( velocity, angle, 0.0 );
	}

	Vec3 normal( 0.0, 0.0, 1.0 );
	Vec3 ejectionVelocity = m_ejectionVelocity * cross( normalize( velocity ), normal  );
	//printf( "Ejection Velocity: %lf, %lf\n", ejectionVelocity.x, ejectionVelocity.y );

	velocity += ejectionVelocity;

	double dt = 0.05;
	Vec3 position = Vec3(0.0, m_state.getWorldPosition().y, 0.0);
	Vec3 acceleration;
	Vec3 direction;

	int steps = 0;
	while ( position.y > m_target.y )
	{
		direction = normalize( velocity );
		acceleration = -Vec3( 0.0, 9.81, 0.0 ) - c_coeff * m_state.getAirDensity() * magnitudeSquared( velocity ) * direction;
		velocity += acceleration * dt;
		position += velocity * dt;
		steps++;
	}
	
	//printf( "Calculated in %d steps\n", steps );

	return position.x;
}


bool Scooter::CP741::inRange()
{
	//printf( "Found: %d Power: %d\n", m_targetFound, m_power );

	if ( ! m_targetFound || ! m_power )
		return false;

	double impactAt45 = calculateImpactDistanceDragless( PULL_UP_ANGLE );
	double distance = calculateHorizontalDistance();
	//printf("%lf, %lf\n", impactAt45, distance );
	return impactAt45 >= distance;
}


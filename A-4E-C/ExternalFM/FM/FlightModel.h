#pragma once
#ifndef FLIGHTMODEL_H
#define FLIGHTMODEL_H
//=========================================================================//
//
//		FILE NAME	: FlightModel.h
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Class for flight model simulation. It's pretty self explanitory.
//
//================================ Includes ===============================//
#include "BaseComponent.h"
#include <iostream>
#include <Common/Maths.h>
#include "Table.h"
#include "Input.h"
#include "Airframe.h"
#include "Engine2.h"
#include "Interface.h"
#include "AeroElement.h"
#include "Timer.h"
#include "AircraftState.h"
#include "MovingAverage.h"
#include "LERX.h"
//=========================================================================//

struct Force
{
	Vec3 pos;
	Vec3 force;
};

namespace Scooter
{//begin namespace

class FlightModel : public BaseComponent
{
public:
	FlightModel(
		AircraftState& state, 
		Input& controls, 
		Airframe& airframe, 
		Engine2& engine, 
		Interface& inter,
		std::vector<LERX>& splines
	);
	~FlightModel();

	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();


	//Utility.

	//Adds a force (and moment caused by it)
	//in the local reference frame of the aircraft.
	inline void addForce(const Vec3& force, const Vec3& pos);
	inline void addForceDir(const Vec3& force, const Vec3& dir);
	inline void addForceElement(AeroElement elem, bool leftWing);
	inline void addForce( const Vec3& force );

	//Setup parameters before calculation.
	inline void setAtmosphericParams(const double density, const double speedOfSound, const Vec3& wind);
	inline void setCOM(const Vec3& com);
	void calculateLocalPhysicsParams(double dt);

	//Actually calculate something.
	inline void L_stab();
	inline void M_stab();
	inline void N_stab();

	void lift();
	void drag();
	inline void sideForce();
	inline void thrustForce();

	inline double elevator();
	inline double aileron();
	inline double rudder();
	void slats(double& dt);
	inline double thrust();

	void calculateAero(double dt);
	void calculateElements();
	void calculateShake(double& dt);
	void checkForOverstress(double dt);

	//Get forces for ED physics engine.
	inline const Vec3& getForce() const;
	inline const Vec3& getMoment() const;

	//Get COM for ED physics engine.
	inline const Vec3& getCOM() const;

	//get yaw rate
	inline double mach();

	//other
	void csvData(std::vector<double>& data);
	inline double toDegrees(double angle);
	inline double toRad(double angle);
	inline int getRandomNumber(int min, int max);
	inline double getCockpitShake();
	inline double getLoadFactor() const;
	inline void setCockpitShakeModifier( double mod );

	inline std::vector<Force>& getForces() { return m_forces; }

	void ImGuiDebugWindow();

private:

	//=====================BIG WARNING=====================//
	//       DO NOT CHANGE THE ORDER OF THESE CONSTANTS
	//DOING SO MAY RESULT IN THE TABLES USING ININTIALISED DATA
	//This is because the constructor constructs based on the order
	//of declaration not the order of the list in the constructor.
	//=====================BIG WARNING=====================//
	//Aircraft constants (METRIC and RADIANS)
				 
	const double m_totalWingArea = 24;
	const double m_totalWingSpan = 8.3;
	const double m_chord = 2.9;
				 
	const double m_horizontalTailArea = 4.8;
	const double m_horizontalTailArm = 5.1;
				 
	const double m_verticalTailArea = 2.9;
	const double m_verticalTailArm = 5.1;
	const double m_wingDihedral = 0.046774824;

	const double m_wingIncidence = 0.0;
				 
	const double m_thrust = 38000;

	//390 KN is the structural limit. 1.5 times safety margin.
	static constexpr double c_wingStructuralLimit = 195000.0 * 1.8;
	double left_wing_break_time = 0.0;
	double right_wing_break_time = 0.0;

//
	double m_q; //0.5*p*V^2 * s * b
	double m_p; //0.25*p*V * s * b^2
	double m_k; //0.5*p*V^2 * s

	//Aircraft Parameters
	Vec3 m_com; //Centre of mass

	//Vec3 m_localAcc;
	//Vec3 m_worldVelocity; //velocity in the world frame
	Vec3 m_airspeed; //speed through the air (world frame)
	//Vec3 m_airspeedLocal; //speed through the air (local aircraft frame)
	double m_scalarVSquared;
	double m_scalarV;
	//double m_aoa; //angle of attack
	double m_aoaPrevious; //previous frame angle of attack
	double m_aoaDot; //aoa per unit time
	MovingAverage<double, 10> m_aoaDotAverage;
	MovingAverage<double, 10> m_betaDotAverage;

	//double m_beta; //angle of slip
	double m_betaPrevious;
	double m_betaDot;

	//For tracking damage
	double m_lwForce = 0.0;
	double m_rwForce = 0.0;

	Vec3 m_CDwindAxesComp; //Drag from various elements, calculated in wind axes

	Vec3 m_wingSurfaceNormalL = { 0.0, cos(m_wingDihedral), sin(m_wingDihedral) };
	Vec3 m_wingSurfaceNormalR = { 0.0, cos(m_wingDihedral), -sin(m_wingDihedral) };
	Vec3 m_hStabSurfaceNormal = { 0.0, 1.0, 0.0 };
	Vec3 m_vStabSurfaceNormal = { 0.0, 0.0, 1.0 };

	//slats
	const double m_slatMass = 20.0; //mass (kg)
	const double m_slatDamping = 15.0; //damping (-)
	const double m_slatSpring = 1000.0; //spring (-)
	const double m_slatArea = 3.0; //flat plate
	const double m_aoaZero = 0.261799388;//0.261799; //aoa in body frame at which slat has zero lift (rad)
	double m_LslatVel; //speed of slat (m/s)
	double m_RslatVel;
	Table slatCL; //lift coefficient for slat airfoil

	//Vec3 m_omegaDot;
	//Vec3 m_omega;
	//Vec3 m_angle;

	Vec3 m_moment; //total moment of aircraft
	Vec3 m_momentStability; //total stability moments in stability frame
	Vec3 m_force; //total force on the aircraft

	//Aircraft Settings
	AircraftState& m_state;
	Engine2& m_engine;
	Airframe& m_airframe;

	//Tables m_ removed for easy of use

	//Lift
	Table CLalpha; //lift with alpha (RADIANS)
	Table dCLflap; //delta lift with flap, alpha (RADIANS)
	Table dCLslat; //delta lift with slat, alpha (RADIANS)
	Table dCLspoiler;
	Table CLde; //lift elevator deflection

	Table CLhstab;
	Table CDhstab;
	Table CLvstab;
	Table CDvstab;

	//Drag
	Table CDalpha; //drag with alpha (RADIANS)
	Table CDi; //induced drag constant
	Table CDmach; //drag with mach
	Table CDflap; //drag with angle of flap (RADIANS)
	Table CDslat;
	Table dCDspoiler;
	Table dCDspeedBrake; //drag with position of speedbrake normalised 0 - 1
	Table CDbeta; //drag with beta (RADIANS)
	Table CDde; //drag due to elevator deflection
	const double CDNoseGear = 0.004;
	const double CDMainGear = 0.0075;

	//Side Force
	Table CYb; //side force with beta

	//Stability Derrivatives
	//Roll
	Table Clb; //roll moment with beta (RADIANS)
	Table Clp; //roll moment due to roll rate (RADIANS per Second)
	Table Clr; //roll moment due to yaw rate (RADIANS per Second)
	Table Cla; //roll moment due to aileron (RADIANS)
	Table Cldr; //roll moment due to rudder (RADIANS)
	Table Cla_a;

	Table CL_ail;
	Table CD_ail;

	//Pitch
	Table Cmalpha; //pitch moment with alpha (MACH)
	Table Cmde; //pitch moment due to elevator (RADIANS)
	Table Cmq; //pitch moment due to pitch rate (RADIANS per Second) [MACH]
	Table Cmadot; //pitch moment due to alpha rate (MACH)
	Table CmM; //pitch moment due to mach number (-)
	Table comp_e; //elevator compression

	//Yaw
	Table Cnb; //yaw moment due to beta (RADIANS)
	Table Cnr; //yaw moment due to yaw rate (RADIANS per Second)
	Table Cndr; //yaw moment due to rudder (RADIANS)
	Table Cnda; //yaw moment due to aileron deflection (Adverse Yaw) (RADIANS)

	Table Cmde_a;
	Table rnd_aoa;

	/*AeroSurface m_elementLW;
	AeroSurface m_elementRW;*/
	AeroElement m_elementLSlat;
	AeroElement m_elementRSlat;
	AeroElement m_elementLFlap;
	AeroElement m_elementRFlap;
	AeroElement m_elementLSpoiler;
	AeroElement m_elementRSpoiler;
	AeroControlElement m_elementHorizontalStab;
	AeroControlElement m_elementVerticalStab;

	/*AeroControlSurface m_elementLAil;
	AeroControlSurface m_elementRAil;*/

	std::vector<AeroElement> m_elements;
	std::vector<AeroControlElement> m_elementsC;
	std::vector<LERX>& m_splines;

	std::vector<Force> m_forces;


	Input& m_controls; //for now

	//Misc
	double m_cockpitShake;
	double m_cockpitShakeModifier = 0.0;

	Timer m_shakeDuration;
	Timer m_shakeTimerSlatL;
	Timer m_shakeTimerSlatR;
	bool prevGearShake;
	bool gearShake;
	bool slatLShake;
	bool slatLShakePrev;
	bool slatRShake;
	bool slatRShakePrev;
	Interface& m_interface;
};

void FlightModel::setCOM(const Vec3& com)
{
	m_com = com;
}

const Vec3& FlightModel::getForce() const
{
	return m_force;
}

const Vec3& FlightModel::getMoment() const
{
	return m_moment;
}

const Vec3& FlightModel::getCOM() const
{
	return m_com;
}

void FlightModel::addForce(const Vec3& force, const Vec3& pos)
{
	//Add the force to the overall force
	m_force += force;

	//Calculate the relative position to the centre of mass
	Vec3 relativePos = pos - m_com;

	//Calculate the "moment" (actually torque)
	Vec3 moment = cross(relativePos, force);

	//Add it on
	m_moment += moment;
}

void FlightModel::addForceDir(const Vec3& force, const Vec3& dir)
{
	//Add the force to the overall force
	m_force += force;

	//Calculate the "moment" (actually torque)
	Vec3 moment = cross(dir, force);

	//Add it on
	m_moment += moment;
}

void FlightModel::addForceElement(AeroElement elem, bool leftWing)
{
	// Add the force to the overall force
	m_force += elem.getForce();

	// Calculate the "moment" (actually torque)
	m_moment += elem.getMoment();

	/*Force f;
	f.force = elem.getForce();
	f.pos = elem.getCOP();

	m_forces.push_back( f );*/

	if ( leftWing )
		m_lwForce += elem.getForce().y;
	else
		m_rwForce += elem.getForce().y;
}

void FlightModel::addForce( const Vec3& force )
{
	m_force += force;

	/*Force f;
	f.force = force;
	f.pos = m_state.getCOM();

	m_forces.push_back( f );*/

}

void FlightModel::L_stab()
{
	//NOTE m_moment.x is no longer correct, it's m_momentStability.x
	
	//m_moment.x += m_q * (Cldr( 0.0 ) * rudder() * m_airframe.getRudderDamage());


	//DO NOT DELETE!!!
	//Cla(m_state.getMach())* Cla_a(std::abs(m_state.getAOA()))* aileron()* m_airframe.getAileronDamage()
	//Clb(0.0)* m_state.getBeta()* m_airframe.getVertStabDamage()
	//m_moment.x += m_p * ( Clp( 0.0 ) * m_state.getOmega().x + Clr( 0.0 ) * m_state.getOmega().y );
}

void FlightModel::M_stab()
{
	double horizDamage = m_airframe.getHoriStabDamage();
	//double wingDamage = (m_airframe.getLWingDamage() + m_airframe.getRWingDamage())/2.0;

	double elev = 0.0;//0.0 * 0.65 * comp_e( m_state.getMach() ) * Cmde_a( std::abs( m_elementHorizontalStab.getAOA() ) ) * (-elevator() + m_airframe.getStabilizer()) * m_airframe.getElevatorDamage();

	m_moment.z += m_k * m_chord * ( elev + CmM( m_state.getMach() ) * 0.15 + 0.008 * m_airframe.getSpeedBrakePosition()) + 
		0.25 * m_scalarV * m_totalWingArea * m_chord * m_chord * horizDamage * (Cmadot( m_state.getMach() ) * m_aoaDot * 6.5 + Cmq( m_state.getMach() ) * m_state.getOmega().z );
	//DO NOT DELETE!!!
	//0.5 * Cmde( m_state.getMach() ) * Cmde_a( std::abs( m_state.getAOA() ) ) * elevator() * m_airframe.getElevatorDamage() + 
	/*Cmalpha(m_state.getMach())* m_state.getAOA()* wingDamage * 1.5
	Cmq(m_state.getMach()) * m_state.getOmega().z + Cmadot(m_state.getMach()) * m_aoaDot*/
}

void FlightModel::N_stab()
{
	double vertDamage = m_airframe.getVertStabDamage();
	m_momentStability.y += m_p * (Cmadot(m_state.getMach()) * m_betaDot * 0.3);
	//printf("betad: %lf\n", m_betaDot);
	
	//DO NOT DELETE!!!
	//m_q * (Cndr(0.0) * rudder() * m_airframe.getRudderDamage()) +
	//-Cnb(m_state.getBeta()) * vertDamage * 0.8
	//	+ m_p * (Cnr(0.0) * m_state.getOmega().y * vertDamage);//(); //This needs to be fixed, constants like 0.8 are temporary!!!
}

double FlightModel::elevator()
{
	return m_airframe.elevatorAngle();
}

double FlightModel::aileron()
{
	return m_airframe.aileronAngle();
}

double FlightModel::rudder()
{
	return m_airframe.rudderAngle();
}

double FlightModel::thrust()
{
	return m_controls.throttleNorm() * m_thrust;
}

void FlightModel::sideForce()
{
	addForce(Vec3(0.0, 0.0, m_k*CYb(0.0)*m_state.getBeta()*0.35));
}

void FlightModel::thrustForce()
{
	m_engine.setAirspeed(m_scalarV);
	//addForce(Vec3(thrust(), 0.0, 0.0), getCOM());
	addForce(Vec3(m_engine.getThrust(), 0.0, 0.0));
}

double FlightModel::mach()
{
	return m_state.getMach();
}

double FlightModel::toDegrees(double angle)
{
	return 360 * angle / (2 * PI);
}

double FlightModel::toRad(double angle)
{
	return (2 * PI) * angle / 360;
}

int FlightModel::getRandomNumber(int min, int max)
{
	static constexpr double fraction{ 1.0 / (RAND_MAX + 1.0) };
	
	return min + static_cast<int>((max - min + 1) * (std::rand() * fraction));
}

double FlightModel::getCockpitShake()
{
	return m_cockpitShake;
}

double FlightModel::getLoadFactor() const
{
	double lf = (m_lwForce + m_rwForce) / (c_wingStructuralLimit * 2.0);
	//printf( "Load Factor: %lf\n", lf );
	return abs(lf);
}

void FlightModel::setCockpitShakeModifier( double mod )
{
	m_cockpitShakeModifier = mod;
}

}//end namespace

#endif
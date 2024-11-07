//=========================================================================//
//
//		FILE NAME	: FlightModel.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Class for flight model simulation. It's pretty self explanitory.
//
//================================ Includes ===============================//
#include <vector>
#include <stdio.h>
#include <algorithm>
#include <fstream>
#include "FlightModel.h"
#include "Data.h"
#include <Common/Maths.h>
#include <Common/Globals.h>
//#include <LuaImGui.h>
#include "lua/lua.h"
#include "Units.h"
#include "Logger.h"
//=========================================================================//

typedef Scooter::Airframe::Damage D;

static int vapourMap[8] = {};
static int vapourMapC[10] = {};

static D wingElementToDamage[] = {D::WING_L_CENTER, D::WING_L_CENTER, D::WING_L_IN, D::WING_L_IN, D::WING_R_IN, D::WING_R_IN, D::WING_R_CENTER, D::WING_R_CENTER};
static D wingElementToDamageC[] = {D::AILERON_L, D::WING_L_OUT, D::WING_L_OUT, D::WING_L_OUT, D::WING_L_CENTER, D::WING_R_CENTER, D::WING_R_OUT, D::WING_R_OUT, D::WING_R_OUT, D::AILERON_L };

constexpr double c_cpX = -0.05;//0.1;

#undef min

//Set everything to zero.
//Vectors already constructor to zero vector.
Scooter::FlightModel::FlightModel
(
	AircraftState& state,
	Input& controls,
	Airframe& airframe,
	Engine2& engine,
	ParameterInterface& inter,
	std::vector<LERX>& splines
):
	m_state(state),
	m_controls(controls),
	m_airframe(airframe),
	m_engine(engine),
	m_interface( inter ),
	m_scalarVSquared(0.0),
	m_scalarV(0.0),
	m_q(0.0),
	m_p(0.0),
	m_k(0.0),
	m_aoaDot(0.0),
	m_aoaPrevious(0.0),
	m_LslatVel(0.0),
	m_RslatVel(0.0),
	m_cockpitShake(0.0),
	m_shakeDuration(0.1),
	m_shakeTimerSlatL(0.1),
	m_shakeTimerSlatR(0.1),

	//m_elementLW(m_state, CLalpha, CDalpha, Vec3(0, 0, -3.0), m_wingSurfaceNormalL, m_totalWingArea/2),
	//m_elementRW(m_state, CLalpha, CDalpha, Vec3(0, 0, 3.0), m_wingSurfaceNormalR, m_totalWingArea/2),
	m_elementLSlat(m_state, AeroElement::HORIZONTAL, dCLslat, CDslat, Vec3( c_cpX, 0, -3.0), m_wingSurfaceNormalL, m_totalWingArea / 2),
	m_elementRSlat(m_state, AeroElement::HORIZONTAL, dCLslat, CDslat, Vec3( c_cpX, 0, 3.0), m_wingSurfaceNormalR, m_totalWingArea / 2),
	m_elementLFlap(m_state, AeroElement::HORIZONTAL, dCLflap, CDflap, Vec3( c_cpX, 0, -3.0), m_wingSurfaceNormalL, m_totalWingArea / 2),
	m_elementRFlap(m_state, AeroElement::HORIZONTAL, dCLflap, CDflap, Vec3( c_cpX, 0, 3.0), m_wingSurfaceNormalR, m_totalWingArea / 2),
	m_elementLSpoiler(m_state, AeroElement::HORIZONTAL, dCLspoiler, dCDspoiler, Vec3( c_cpX, 0, -3.0), m_wingSurfaceNormalL, m_totalWingArea / 2),
	m_elementRSpoiler(m_state, AeroElement::HORIZONTAL, dCLspoiler, dCDspoiler, Vec3( c_cpX, 0, 3.0), m_wingSurfaceNormalR, m_totalWingArea / 2),
	m_elementHorizontalStab(m_state, m_airframe, AeroElement::HORIZONTAL_STAB, CLhstab, CDhstab, &comp_e, Vec3(-5.1, 1.65, 0.0), m_hStabSurfaceNormal, 4.4),
	m_elementVerticalStab(m_state, m_airframe, AeroElement::RUDDER, CLvstab, CDvstab, Vec3(-4.8, 2.7, 0.0), m_vStabSurfaceNormal, 5.3),
	//m_elementLAil(m_state, dCLflap, CDflap, Vec3(0, 0, -3.2), m_wingSurfaceNormalL, m_totalWingArea/5),
	//m_elementRAil(m_state, dCLflap, CDflap, Vec3(0, 0, 3.2), m_wingSurfaceNormalR,  m_totalWingArea/5),

	//Setup tables
	//CLalpha(d_CLalpha, -0.26981317, 1.57079633), OLD - DONT DELETE
	//CLalpha(d_CLalpha, -1.5708, 1.5708),
	CLalpha(d_CLalpha, -PI, PI),
	dCLflap(d_CLflap, -0.26981317, 1.57079633),
	dCLslat(d_CLslat, -0.26981317, 1.57079633),
	dCLspoiler({-0.35}, 0, 1),
	CLde(d_CLde, 0.157982, 1.000377),
	//CDalpha(d_CDalpha, -1.57079633, 1.57079633),
	CDalpha(d_CDalpha, -PI, PI),
	CDi( d_CDialpha, c_CDialphaMin, c_CDialphaMax ),
	CDmach(d_CDmach,0.0, 1.8),
	CDflap(d_CDflap, -1.57079633, 1.57079633),
	CDslat(d_CDslat, -1.57079633, 1.57079633),
	dCDspoiler({ 0.45 }, 0, 1),
	dCDspeedBrake({0.08}, 0.0, 1.0),
	CDbeta(d_CDbeta,-1.57, 1.57),
	CDde({0.005}, c_elevatorDown, c_elevatorUp),

	//CLhstab(d_CL_hstab_alpha, -1.57079633, 1.57079633),
	CLhstab(d_CL_hstab_alpha, -PI, PI),
	CDhstab(d_CD_hstab_alpha, -PI, PI),
	//CLvstab(d_CL_vstab_aoa, -1.57079633, 1.57079633),
	CLvstab(d_CL_vstab_aoa, -PI, PI),
	CDvstab(d_CD_vstab_alpha, -PI, PI),

	comp_e(d_comp_e, 0.0, 1.0),

	CYb({-1}, 0.0, 1.0),

	Clb({ -0.01 }, 0.0, 1.0),
	Clp({ -0.0 }, 0.0, 1.0), //-0.3
	Clr({ 0.0 }, 0.0, 1.0), //0.15
	//Cla({ 0.220, 0.037 }, 0.0, 2.0), //110
	Cla({ 0.220 }, 0.0, 1.0),
	Cldr({ 0.0 }, 0.0, 1.0),
	Cla_a({1.0, 0.3}, 0.436332313, 0.698131701),

	CL_ail(d_CL_ail, 0.0, 0.872664626),
	CD_ail(d_CD_ail, 0.0, 0.872664626),

	Cmalpha(d_Cmalpha, 0.1, 1.0019),
	Cmde(d_Cmde, 0, 1.00216078), //x = mach
	Cmq(d_Cmq, 0.13176098, 1.0006616),
	Cmadot(d_Cmadot, 0.0, 1.0),
	CmM(d_CmM, 0.06761245, 1.0),
	Cmde_a({1.2, 0.1}, 30.0_deg, 40.0_deg),
	
	//Cnb({0.36}, 0.0, 1.0), //0.12
	Cnb(d_Cnb, -0.785398163, 0.785398163),
	Cnr({-0.08}, 0.0, 1.0), //-0.15
	Cndr({-0.1}, 0.0, 1.0),
	Cnda({0.2}, 0.0, 1.0),

	//slats
	slatCL({-0.15, 0.15}, 0.261799, 0.436332313),

	rnd_aoa(d_rnd_aoa, -0.34906585, 0.41887902),
	m_splines(splines)
{
	//m_elements.push_back(AeroSurface(m_state, CLalpha, CDalpha, Vec3(0.0, 0.0, -0.1067866894), m_wingSurfaceNormalL, 1.9737953980 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -0.5399751247), m_wingSurfaceNormalL, 1.8047195280 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -0.9731336040), m_wingSurfaceNormalL, 1.6356436570 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -1.4062517670), m_wingSurfaceNormalL, 1.4665677860 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -1.8393138510), m_wingSurfaceNormalL, 1.2974919160 + 0.21931));
	//wing+ail								  
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -2.2722946510), m_wingSurfaceNormalL, 1.1284160450 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -2.7051511890), m_wingSurfaceNormalL, 0.9593401748 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -3.1378037070), m_wingSurfaceNormalL, 0.7902643043 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -3.5700856160), m_wingSurfaceNormalL, 0.6211884337 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, -4.0014189490), m_wingSurfaceNormalL, 0.3500000000 + 0.21931));

	//m_elements.push_back(AeroSurface(m_state, CLalpha, CDalpha, Vec3(0.0, 0.0, 0.1067866894), m_wingSurfaceNormalR, 1.9737953980));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 0.5399751247), m_wingSurfaceNormalR, 1.8047195280 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 0.9731336040), m_wingSurfaceNormalR, 1.6356436570 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 1.4062517670), m_wingSurfaceNormalR, 1.4665677860 + 0.21931));
	m_elements.push_back(AeroElement(m_state, AeroElement::HORIZONTAL, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 1.8393138510), m_wingSurfaceNormalR, 1.2974919160 + 0.21931));
	//wing+ail								   
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 2.2722946510), m_wingSurfaceNormalR, 1.1284160450 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 2.7051511890), m_wingSurfaceNormalR, 0.9593401748 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 3.1378037070), m_wingSurfaceNormalR, 0.7902643043 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 3.5700856160), m_wingSurfaceNormalR, 0.6211884337 + 0.21931));
	m_elementsC.push_back(AeroControlElement(m_state, m_airframe, AeroElement::AILERON, CLalpha, CDalpha, Vec3( c_cpX, 0.0, 4.0014189490), m_wingSurfaceNormalR, 0.3500000000 + 0.21931));


	int splineSize = int(splines.size() / 2);
	int elementSize = int(m_elements.size() / 2);

	for ( int i = 0; i < elementSize; i++ )
	{
		vapourMap[i] = i;
		vapourMap[i + elementSize] = i + splineSize;
	}

	for ( int i = 0; i < m_elementsC.size() / 2; i++ )
	{
		vapourMapC[i] = i + elementSize;
		vapourMapC[i + m_elementsC.size() / 2] = i + splineSize + elementSize;
	}

	/*LuaImGui::AddImGuiItem( "Airframe", "Damage", [this]() {
		ImGuiDebugWindow();
	} );*/
}

Scooter::FlightModel::~FlightModel()
{

}

//Seriously need to set EVERY VARIABLE to zero (or approriate value if zero causes singularity) in the constructor and 
//in this function. Otherwise Track's become unusable because of the butterfly effect.
void Scooter::FlightModel::zeroInit()
{
	m_q = 0.0;
	m_p = 0.0;
	m_k = 0.0;

	m_scalarVSquared = 0.0;
	m_scalarV = 0.0;
	m_aoaPrevious = 0.0;
	m_betaPrevious = 0.0;
	m_betaDot = 0.0;

	m_LslatVel = 0.0;
	m_RslatVel = 0.0;

	m_moment = Vec3();
	m_force = Vec3();

	m_com = Vec3();
	m_airspeed = Vec3();

	m_CDwindAxesComp = Vec3();

	/*m_elementLW.zeroInit();
	m_elementRW.zeroInit();*/
	m_elementLSlat.zeroInit();
	m_elementRSlat.zeroInit();
	m_elementLFlap.zeroInit();
	m_elementRFlap.zeroInit();
	m_elementLSpoiler.zeroInit();
	m_elementRSpoiler.zeroInit();

	gearShake = false;
	prevGearShake = false;
	slatLShake = false;
	slatLShakePrev = false;
	slatRShake = false;
	slatRShakePrev = false;

}

void Scooter::FlightModel::coldInit()
{
	zeroInit();
}

void Scooter::FlightModel::hotInit()
{
	zeroInit();
}

void Scooter::FlightModel::airborneInit()
{
	zeroInit();
}

void Scooter::FlightModel::calculateAero(double dt)
{
	calculateLocalPhysicsParams(dt);
	slats( dt );
	lift();
	drag();
	calculateElements();
	sideForce();
	thrustForce();

	L_stab();
	M_stab();
	N_stab();

	//Convert from stability axes to body.
	double cosa = cos( m_state.getAOA() );
	double sina = sin( m_state.getAOA() );
	m_moment.x += m_momentStability.x * cosa - m_momentStability.y * sina;
	m_moment.y += m_momentStability.y * cosa - m_momentStability.x * sina;

	checkForOverstress( dt );

	//printf("roll rate: %lf\n", m_state.getOmega().x);
	
	calculateShake(dt);
}

void Scooter::FlightModel::calculateLocalPhysicsParams(double dt)
{
	m_force = Vec3();
	m_moment = Vec3();
	m_momentStability = Vec3();

	double dAOA = m_state.getAOA() - m_aoaPrevious;
	//printf( "%lf - %lf = %lf\n", m_state.getAOA(), m_aoaPrevious, dAOA );
	double dAOAOpposite;

	if (dAOA >= 0.0)
	{
		dAOAOpposite = 2.0 * PI - dAOA;
	}
	else
	{
		dAOAOpposite = -2.0 * PI - dAOA;
	}

	if (fabs(dAOA) > fabs(dAOAOpposite))
	{
		//printf( "Took opposite: %lf, instead of %lf\n", dAOAOpposite, dAOA );
		dAOA = dAOAOpposite;
		
	}

	double dBeta = m_state.getBeta() - m_betaPrevious;
	double dBetaOpposite;

	if (dBeta >= 0.0)
	{
		dBetaOpposite = 2.0 * PI - dBeta;
	}
	else
	{
		dBetaOpposite = -2.0 * PI - dBeta;
	}

	if (fabs(dBeta) > fabs(dBetaOpposite))
	{
		dBeta = dBetaOpposite;
		//printf( "Took opposite: %lf\n", dBeta );
	}

	//Clamped to prevent strange behaviour from the lack of precision in the timestep.
	double aoaDot = clamp(dAOA / dt, -10.0 * PI, 10.0 * PI);
	m_aoaDotAverage.add( aoaDot );
	m_aoaDot = m_aoaDotAverage.value();

	//Note we should be able to remove this hack now.
	//Nose compression + Lower than 50 kts.
	if ( m_airframe.getNoseCompression() > 0.05 && magnitude(m_state.getLocalSpeed()) < 25.0 )
	{
		m_aoaDot = 0.0;
	}

	double betaDot = clamp( dBeta / dt, -10 * PI, 10.0 * PI );
	m_betaDotAverage.add( betaDot );
	m_betaDot = m_betaDotAverage.value();

	//Get airspeed and scalar speed squared.
	m_airspeed = m_state.getWorldVelocity() - m_state.getWorldWindVelocity();

	m_scalarVSquared = m_airspeed.x * m_airspeed.x + m_airspeed.y * m_airspeed.y + m_airspeed.z * m_airspeed.z;

	m_scalarV = sqrt(m_scalarVSquared);
	m_engine.setAirspeed(m_scalarV);
	m_interface.setAirspeed(m_scalarV);
	m_state.setMach(m_scalarV / m_state.getSpeedOfSound());

	m_aoaPrevious = m_state.getAOA();
	m_betaPrevious = m_state.getBeta();

	m_k = m_scalarVSquared * m_state.getAirDensity() * 0.5 * m_totalWingArea;
	m_q = m_k * m_totalWingSpan;
	m_p = m_scalarV * m_state.getAirDensity() * 0.25 * m_totalWingArea * m_totalWingSpan * m_totalWingSpan;
}

void Scooter::FlightModel::lift()
{
	addForce(Vec3(0.0, m_k * (CLde(m_state.getMach()) * elevator()), 0.0));
}

void Scooter::FlightModel::drag()
{
	double geNormalFactor = abs( normalize( m_state.getSurfaceNormal() ) * normalize( -m_state.getGlobalDownVectorInBody() ) );
	double geFactor = clamp(m_totalWingSpan - m_state.getSurfaceHeight(), 0.0, m_totalWingSpan) / m_totalWingSpan;

	constexpr double geStrength = 0.4;
	double ge = ( 1.0 - geStrength * geFactor * geNormalFactor );

	//printf( "Surface Height: %lf, Factor: %lf, Normal Factor: %lf\n", m_state.getSurfaceHeight(), geFactor, geNormalFactor );

	double CD = dCDspeedBrake(0.0) * m_airframe.getSpeedBrakePosition() +
		CDbeta(m_state.getBeta()) +
		CDde(0.0) * abs(elevator()) +
		CDmach(m_state.getMach()) + ge * CDi(m_state.getAOA()) * pow(CLalpha(m_state.getAOA()), 2.0) +
		m_airframe.getGearLPosition() * CDMainGear +
		m_airframe.getGearRPosition() * CDMainGear +
		m_airframe.getGearNPosition() * CDNoseGear;


	m_CDwindAxesComp.y = 0;
	m_CDwindAxesComp.z = 0;
	m_CDwindAxesComp.x = -m_k * CD;
}

void Scooter::FlightModel::calculateElements()
{
	//m_forces.clear();

	m_lwForce = 0.0;
	m_rwForce = 0.0;

	Vec3 dragElem = windAxisToBody(m_CDwindAxesComp, m_state.getAOA(), m_state.getBeta() );
	
	m_elementLSlat.setLDFactor(1.6 * m_airframe.getSlatLPosition() * m_airframe.getFlapDamage(), m_airframe.getSlatLPosition() * m_airframe.getFlapDamage() );
	m_elementRSlat.setLDFactor(1.6 * m_airframe.getSlatRPosition() * m_airframe.getFlapDamage(), m_airframe.getSlatRPosition() * m_airframe.getFlapDamage() );
	m_elementLFlap.setLDFactor(m_airframe.getFlapsPosition() * m_airframe.getFlapDamage(), m_airframe.getFlapsPosition());
	m_elementRFlap.setLDFactor(m_airframe.getFlapsPosition() * m_airframe.getFlapDamage(), m_airframe.getFlapsPosition());
	m_elementLSpoiler.setLDFactor(m_airframe.getSpoilerPosition() * m_airframe.getSpoilerDamage(), m_airframe.getSpoilerPosition());
	m_elementRSpoiler.setLDFactor(m_airframe.getSpoilerPosition() * m_airframe.getSpoilerDamage(), m_airframe.getSpoilerPosition());
	//m_elementHorizontalStab.setLDFactor( 0.25 * m_airframe.getHoriStabDamage(), 0.85 * m_airframe.getHoriStabDamage());
	//m_elementVerticalStab.setLDFactor( 0.35 * m_airframe.getVertStabDamage(), 0.85 * m_airframe.getVertStabDamage());

	m_elementHorizontalStab.setLDFactor( 1.0 * m_airframe.getHoriStabDamage(), 1.0 * m_airframe.getHoriStabDamage() );
	m_elementVerticalStab.setLDFactor( 0.35 * m_airframe.getVertStabDamage(), 0.85 * m_airframe.getVertStabDamage() );
	//printf("beta: %lf, aoa: %lf\n", toDegrees(m_elementVerticalStab.getAOA()));

	/*m_elementLAil.setLDFactor(m_airframe.getAileron() * m_airframe.getAileronDamage(), m_airframe.getAileron() * 0.05 * m_airframe.getAileronDamage());
	m_elementRAil.setLDFactor(-m_airframe.getAileron() * m_airframe.getAileronDamage(), -m_airframe.getAileron() * 0.05 * m_airframe.getAileronDamage());*/

	m_elementLSlat.calculateElementPhysics();
	m_elementRSlat.calculateElementPhysics();
	m_elementLFlap.calculateElementPhysics();
	m_elementRFlap.calculateElementPhysics();
	m_elementLSpoiler.calculateElementPhysics();
	m_elementRSpoiler.calculateElementPhysics();
	//m_elementLAil.calculateElementPhysics();
	//m_elementRAil.calculateElementPhysics();
	m_elementHorizontalStab.calculateElementPhysics();

	Logger::entry( m_elementHorizontalStab.getAOA() );
	Logger::entry( CLhstab( m_elementHorizontalStab.getAOA() ) );
	Logger::entry( m_airframe.getElevator() );


	m_elementVerticalStab.calculateElementPhysics();

	//printf("aoa hstab: %lf\n", toDegrees(m_elementHorizontalStab.m_aoa));
	//printf("forceL: %lf, %lf, %lf  forceR: %lf, %lf, %lf\n", m_elementLAil.getForce().x, m_elementLAil.getForce().y, m_elementLAil.getForce().z, m_elementRAil.getForce().x, m_elementRAil.getForce().y, m_elementRAil.getForce().z);

	addForceElement(m_elementLSlat, true);
	addForceElement(m_elementRSlat, false);
	addForceElement(m_elementLFlap, true);
	addForceElement(m_elementRFlap, false);
	addForceElement(m_elementLSpoiler, true);
	addForceElement(m_elementRSpoiler, false);

	//m_moment += m_elementLAil.getMoment();
	//m_moment += m_elementRAil.getMoment();
	m_moment += m_elementHorizontalStab.getMoment();
	m_moment += m_elementVerticalStab.getMoment();

	//addForceElement(m_elementHorizontalStab, false);
	//addForceElement(m_elementVerticalStab, false);

	// i:0-8 = LW, i:8-17 = RW
	float damage = 1.0;

	for (int i = 0; i < m_elements.size(); i++)
	{
		bool leftWing = i < m_elements.size() / 2;
		/*if ( leftWing )
		{
			damage = m_airframe.getLWingDamage();
		}
		else
		{
			damage = m_airframe.getRWingDamage();
		}*/
		damage = float( m_airframe.getDamageElement( wingElementToDamage[i] ) );

		m_elements[i].setLDFactor(1.0 * damage, 0.7 * damage);
		m_elements[i].calculateElementPhysics();

		if ( m_splines.size() )
			m_splines[vapourMap[i]].setOpacity(m_elements[i].getOpacity());

		addForceElement(m_elements[i], leftWing );

		//printf("id: %d, aoa: %lf, beta: %lf\n", i, toDegrees(m_elements[i].getAOA()), toDegrees(m_elements[i].getBeta()));
	}

	for (int i = 0; i < m_elementsC.size(); i++)
	{
		bool leftWing = i < m_elementsC.size() / 2;
		/*if ( leftWing )
		{
			damage = m_airframe.getLWingDamage();
		}
		else
		{
			damage = m_airframe.getRWingDamage();
		}*/
		damage = float( m_airframe.getDamageElement( wingElementToDamageC[i] ) );

		m_elementsC[i].setLDFactor(1.0 * damage, 0.7 * damage);
		m_elementsC[i].calculateElementPhysics();

		if ( m_splines.size() )
		{
			m_splines[vapourMapC[i]].setOpacity( m_elementsC[i].getOpacity() );
			if ( i == (m_elementsC.size() - 1) || i == (-1 + m_elementsC.size() / 2) )
			{
				m_splines[vapourMapC[i] + 1].setOpacity( m_elementsC[i].getOpacity() );
			}
		}


		addForceElement(m_elementsC[i], leftWing);
		//printf("id: %d, aoa: %lf, beta: %lf\n", i, toDegrees(m_elements[i].getAOA()), toDegrees(m_elements[i].getBeta()));
	}

	//printf("[HSTAB] aoa: %lf, beta: %lf, moment: %lf, %lf, %lf\n", toDegrees(m_elementHorizontalStab.getAOA()), toDegrees(m_elementHorizontalStab.getBeta()), m_elementHorizontalStab.getMoment().x, m_elementHorizontalStab.getMoment().y, m_elementHorizontalStab.getMoment().z);
	//printf("[VSTAB] aoa: %lf, beta: %lf, moment: %lf, %lf, %lf\n", toDegrees(m_elementVerticalStab.getAOA()), toDegrees(m_elementVerticalStab.getBeta()), m_elementVerticalStab.getMoment().x, m_elementVerticalStab.getMoment().y, m_elementVerticalStab.getMoment().z);

	addForce(dragElem);
}

void Scooter::FlightModel::slats(double& dt)
{
	if ( m_airframe.getSlatsLocked() )
	{
		m_LslatVel = 0.0;
		m_RslatVel = 0.0;
		m_airframe.setSlatLPosition( 0.0 );
		m_airframe.setSlatRPosition( 0.0 );

		return;
	}

	// Direction of the slat slider.
	//Vec3 accDirection( -0.94, 0.34, 0.0 );
	Vec3 accDirection = normalize(Vec3( -0.94, 0.34, 0.0 ));

	Vec3 gravityVec = m_state.getGlobalDownVectorInBody() * m_slatMass * 9.8;

	double gravity = gravityVec * accDirection;

	double forceL = (m_elementLSlat.get_kElem() / m_totalWingArea) * m_slatArea * slatCL(m_elementLSlat.getAOA());
	double forceR = (m_elementLSlat.get_kElem() / m_totalWingArea) * m_slatArea * slatCL(m_elementRSlat.getAOA());

	//printf( "%lf, %lf\n", forceL, forceR );
	
	double accAircraft = accDirection * m_state.getLocalAcceleration();

	double x_L = m_airframe.getSlatLPosition();
	double x_R = m_airframe.getSlatRPosition();

	double a_L = accAircraft + (0.09 * forceL - gravity - m_slatDamping * m_LslatVel - 0.09 * m_slatSpring * (x_L-1.5) ) / m_slatMass;
	double a_R = accAircraft + (0.09 * forceR - gravity  - m_slatDamping * m_RslatVel - 0.09 * m_slatSpring * (x_R-1.5) ) / m_slatMass;

	m_LslatVel += a_L * dt;
	m_RslatVel += a_R * dt;

	x_L += m_LslatVel * dt;
	x_R += m_RslatVel * dt;
	
	if ( x_L < 0.0 )
	{
		x_L = 0.0;
		m_LslatVel = -m_LslatVel*0.3;
	}
	else if ( x_L > 1.0 )
	{
		x_L = 1.0;
		m_LslatVel = -m_LslatVel*0.3;
	}

	if ( x_R < 0.0 )
	{
		x_R = 0.0;
		m_RslatVel = -m_RslatVel*0.3;
	}
	else if ( x_R > 1.0 )
	{
		x_R = 1.0;
		m_RslatVel = -m_RslatVel*0.3;
	}

	m_airframe.setSlatLPosition( x_L );
	m_airframe.setSlatRPosition( x_R );
}

void Scooter::FlightModel::checkForOverstress( double dt )
{
	static constexpr double wing_break_time = 0.2;

	if ( abs(m_lwForce) > c_wingStructuralLimit )
	{
		left_wing_break_time += dt;

		if ( left_wing_break_time > wing_break_time )
		{
			left_wing_break_time = 0.0;
			m_airframe.setDamageDelta( Airframe::Damage::WING_L_IN, float(random()) );
			m_airframe.setDamageDelta( Airframe::Damage::WING_L_CENTER, 1.0f );
		}
	}
	else
	{
		left_wing_break_time = 0.0;
	}
		

	if ( abs(m_rwForce) > c_wingStructuralLimit )
	{
		right_wing_break_time += dt;

		if ( right_wing_break_time > wing_break_time )
		{
			right_wing_break_time = 0.0;
			m_airframe.setDamageDelta( Airframe::Damage::WING_R_IN, float(random()) );
			m_airframe.setDamageDelta( Airframe::Damage::WING_R_CENTER, 1.0f );
		}
	}
	else
	{
		right_wing_break_time = 0.0;
	}
}

void Scooter::FlightModel::calculateShake(double& dt)
{
	

	// cockpit shake calculations
	double shakeAmplitude{ 0.0 };
	double shakeInstGear = 0.0;
	double shakeInstSlat = 0.0;
	double buffetAmplitude = 0.6;
	double x{ 0.0 };

	// 20 - 28
	double aoa = toDegrees( std::abs( m_state.getAOA() ) );
	if ( m_scalarV > 30.0 )
		shakeAmplitude = clamp( (aoa - 10.0) / 15.0, 0.0, 1.0 );
	m_interface.setCockpitRattle( shakeAmplitude );
	m_interface.setLoadFactor( getLoadFactor() );
	shakeAmplitude *= buffetAmplitude;

	// GEAR CONTRIBUTION

	double gearContinousShake = (m_airframe.getGearLPosition() + m_airframe.getGearRPosition() + m_airframe.getGearNPosition()) / 3.0 * 0.8;


	if (m_airframe.getGearLPosition() > 0.99 || m_airframe.getGearLPosition() < 0.01)
	{
		gearShake = true;
	}
	else if (m_airframe.getGearRPosition() > 0.99 || m_airframe.getGearLPosition() < 0.01)
	{
		gearShake = true;
	}
	else if (m_airframe.getGearNPosition() > 0.99 || m_airframe.getGearLPosition() < 0.01)
	{
		gearShake = true;
	}
	else
	{
		gearShake = false;
	}

	if (gearShake && !prevGearShake)
	{
		m_shakeDuration.startTimer();
		prevGearShake = true;
	}
	else if (!gearShake)
	{
		prevGearShake = false;
	}

	// SLATS
	if ((m_airframe.getSlatLPosition() > 0.95 || m_airframe.getSlatLPosition() < 0.05))
	{
		slatLShake = true;
	}
	else
	{
		slatLShake = false;
	}

	if ((m_airframe.getSlatRPosition() > 0.95 || m_airframe.getSlatRPosition() < 0.05))
	{
		slatRShake = true;
	}
	else
	{
		slatRShake = false;
	}


	if (slatLShake && !slatLShakePrev)
	{
		m_shakeTimerSlatL.startTimer();
		slatLShakePrev = true;
	}
	else if (!slatLShake)
	{
		slatLShakePrev = false;
	}

	if (slatRShake && !slatRShakePrev)
	{
		m_shakeTimerSlatR.startTimer();
		slatRShakePrev = true;
	}
	else if (!slatRShake)
	{
		slatRShakePrev = false;
	}

	if (m_shakeTimerSlatL.getState())
	{
		shakeInstSlat += 0.25;
	}
	if (m_shakeTimerSlatR.getState())
	{
		shakeInstSlat += 0.25;
	}

	double slatsContinousShake = (m_airframe.getSlatLPosition() + m_airframe.getSlatRPosition()) / 2.0 * 0.05;


	// FLAPS CONTRIBUTION
	double flapsContinousShake = m_airframe.getFlapsPosition() * 0.06;
	
	
	// SPEED BRAKES CONTRIBUTION
	double speedBrakesContinousShake = m_airframe.getSpeedBrakePosition() * 0.12;
	

	m_shakeDuration.updateLoop(dt);
	m_shakeTimerSlatL.updateLoop(dt);
	m_shakeTimerSlatR.updateLoop(dt);

	if (m_shakeDuration.getState())
	{
		shakeInstGear += 0.5;
	}
	//printf(gearShake ? "true" : "false");
	//printf(prevGearShake ? "true" : "false");

	double airspeedScale = clamp((1.0 / 50.0) * (m_scalarV - 50.0), 0.0, 1.0);

	double shakeGroupA = airspeedScale * std::min(flapsContinousShake + gearContinousShake + slatsContinousShake, 0.075);
	double shakeGroupB = airspeedScale * speedBrakesContinousShake;
	double shakeGroupInst = std::min(shakeInstGear + shakeInstSlat, 1.5);
	
	//printf("shake: %lf\n", shakeAmplitude);
	
	m_cockpitShake = shakeAmplitude + shakeGroupA + shakeGroupB + shakeGroupInst;
	m_cockpitShake *= m_cockpitShakeModifier;
	
}

//void Scooter::FlightModel::shakeInst()
//{
//	m_cockpitShake = 100.0;
//}

void Scooter::FlightModel::csvData(std::vector<double>& data)
{
	

	
}

//void Scooter::FlightModel::ImGuiDebugWindow()
//{
//	ImGui::Text( "Alpha: %lf", m_state.getAOA() / 1.0_deg );
//	ImGui::Text( "Beta: %lf", m_state.getBeta() / 1.0_deg );
//}
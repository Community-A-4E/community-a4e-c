#pragma once
//=========================================================================//
//
//		FILE NAME	: AeroElement.h
//		AUTHOR		: TerjeTL
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Provides element classes for aerodynamics simulation.
//
//================================ Includes ===============================//
//utils
#include <iostream>
#include <fstream>
#include <algorithm>
#include <Common/Maths.h>
#include "Table.h"

//classes
#include "BaseComponent.h"
#include "Interface.h"
#include "Airframe.h"
#include "AircraftState.h"
#undef max
//=========================================================================//

namespace Scooter
{//begin namespace
	class FlightModel;

	class AeroElement : public BaseComponent
	{
	public:
		enum Type
		{
			ELEVATOR,
			HORIZONTAL_STAB,
			RUDDER,
			AILERON,
			HORIZONTAL,
			VERTICAL
		};

		AeroElement(AircraftState& state, Type type, Table& CLalpha, Table& CDalpha, Vec3 cp, Vec3 surfaceNormal, double area);
		virtual ~AeroElement() {};

		virtual void zeroInit();
		virtual void coldInit();
		virtual void hotInit();
		virtual void airborneInit();

		virtual void elementLift();
		virtual void elementDrag();
		virtual void calculateElementPhysics();
		virtual double controlInput() { return 0.0; }; // will be overridden for elements with control surfaces

		inline void setLDFactor(double liftFactor, double dragFactor); //manually tune lift& drag externally..
		inline void setLFactor(double liftFactor);
		inline void setDFactor(double dragFactor);

		inline void updateLERX();
		inline float getOpacity() const;

		inline double getAOA() { return m_aoa; }
		inline double getBeta() { return m_beta; }
		inline double get_kElem() { return m_kElem; }
		inline Vec3 getForce() { return m_RForceElement; }
		inline Vec3 getMoment() { return m_moment; }
		inline Vec3 getCOP() { return m_cp; }

	protected:
		const double m_area; // Area of element [m]
		const Vec3 m_cp; // centre of pressure
		const Vec3 m_surfaceNormal;

		double m_scalarAirspeed = 0.0;
		double m_kElem = 0.0; // m_k
		double m_aoa = 0.0;
		double m_beta = 0.0;
		float m_opacity;
		double m_liftFactor;
		double m_dragFactor;
		float m_damageElem = 1.0f; // for now..
		
		Vec3 m_airspeed;
		Vec3 m_liftVec;
		Vec3 m_dragVec;
		Vec3 m_LDwindAxes;
		Vec3 m_RForceElement;
		Vec3 m_moment;
		
		bool m_aoaModifier;
		Type m_type; // determines caluculations to be applied
		
		Table& m_CLalpha;
		Table& m_CDalpha;
		AircraftState& m_state;
	};

	class AeroControlElement : public AeroElement
	{
	public:
		AeroControlElement(AircraftState& state, Airframe& airframe, Type controlSurfaceType, Table& CLalpha, Table& CDalpha, Vec3 cp, Vec3 surfaceNormal, double area);
		AeroControlElement(AircraftState& state, Airframe& airframe, Type controlSurfaceType, Table& CLalpha, Table& CDalpha, Table* compressibility, Vec3 cp, Vec3 surfaceNormal, double area);
		virtual ~AeroControlElement() {}
		
		virtual double controlInput() override;
	
	private:
		Table* m_compressElev; // this is a bit pointless. better to use a dummy table ?
		Airframe& m_airframe;
	};
	void AeroElement::setLDFactor(double liftFactor, double dragFactor)
	{
		m_liftFactor = liftFactor;
		m_dragFactor = dragFactor;
	}

	void AeroElement::setLFactor(double liftFactor)
	{
		m_liftFactor = liftFactor;
	}
	void AeroElement::setDFactor(double dragFactor)
	{
		m_dragFactor = dragFactor;
	}

	void AeroElement::updateLERX()
	{
		double force = std::max(m_LDwindAxes.y / m_area, 0.0);

		//                         onset +  wing fade out
		const double vapourPoint = 15000 + 250 * (abs(m_cp.z) / (c_wingSpan / 2.0));

		//                     lerp the opacity
		m_opacity = float(clamp((force - vapourPoint) / 4000.0, 0.0, 0.8));

	}

	float AeroElement::getOpacity() const
	{
		return m_opacity;
	}
} //end namespace
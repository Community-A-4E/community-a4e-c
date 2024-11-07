#pragma once
#include "Interface.h"
#include "AircraftState.h"
#include "Damage.h"

namespace Scooter
{

class AirDataComputer
{
public:
	AirDataComputer(ParameterInterface& inter, AircraftState& state);
	void update(double dt);

	double GetTASAcceleration() { return m_tas_acceleration; }


private:

	void calculateTAS();
	void calculateEAS();
	void calculateCAS();
	void calculateTASXZComponents();
	void calculateBaroAlt();

	ParameterInterface& m_interface;
	AircraftState& m_state;

	double m_tas_acceleration = 0.0;
	double m_tas = 0.0;
	double m_tas_prev = 0.0;


	double m_eas = 0.0;
	double m_cas = 0.0;

	double m_tasX = 0.0;
	double m_tasZ = 0.0;

	double m_baroAlt = 0.0;

	std::function<void(DamageObject&, double)> on_damage = []( DamageObject& object, double integrity ) {
		if ( DamageProcessor::GetDamageProcessor().Random() > integrity )
		{
			printf( "%s failed\n", object.GetName().c_str() );
			object.SetIntegrity( 0.0 );
		}
	};

	std::shared_ptr<DamageObject> m_pitot_damage = DamageProcessor::MakeDamageObject( "Pitot Tube", DamageCell::NOSE_LEFT_SIDE, on_damage );
	std::shared_ptr<DamageObject> m_static_damage = DamageProcessor::MakeDamageObject( "Static Port", DamageCell::NOSE_LEFT_SIDE, on_damage );

};

} //end namespace Scooter


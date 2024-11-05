#pragma once
#include "BaseComponent.h"
#include "Engine2.h"
#include <Common/Maths.h>
#include "Data.h"
#include <assert.h>

//kg/s
#define c_fuelTransferRateWingToFuse 1.8 
#define c_fuelTransferRateExternWingToWing 0.60
#define c_fuelTransferRateExternCentreToWing 0.69
#define c_fuelTransferRateWingToFuseEmergency 1.1

//Pressure at which, with no boost pump, we start to lose engine power
//due to not being able to provide enough fuel to the engine.
#define c_lowFuelFlowPressure 81000.0
#define c_lowFuelFlowPressure50Percent 30000.0
//#define c_fuelTransferLowRate  

#define c_fuelInLines 10.0

namespace Scooter
{

class FuelSystem2 : public BaseComponent
{
public:

	FuelSystem2( Scooter::Engine2& engine, Scooter::AircraftState& state );
	virtual void zeroInit();
	virtual void coldInit();
	virtual void hotInit();
	virtual void airborneInit();

	enum Tank
	{
		TANK_FUSELAGE,
		TANK_WING,
		TANK_EXTERNAL_LEFT,
		TANK_EXTERNAL_CENTRE,
		TANK_EXTERNAL_RIGHT,
		NUMBER_OF_TANKS
	};

	void addFuel( double dm, bool wingFirst = false );
	void drawFuel( double dm );
	void update( double dt );
	bool handleInput( int command, float value );

	inline void setUnlimitedFuel( bool state );

	inline bool hasFuel() const;
	inline void updateMechPumpPressure();
	inline double transferFuel( Tank from, Tank to, double dm );
	inline double addFuelToTank( Tank tank, double dm, double min = 0.0 );
	inline double transferRateFactor();
	inline bool externalFull() const;

	inline void setExternalTankPressure( bool pressure );
	inline void setMechPumpPressure( bool pressure );
	inline void setWingTankPressure( bool pressure );
	inline void setWingTankBypass( bool bypass );
	inline void setBoostPumpPower( bool power );
	inline void setExternalTankFlightRefuel( bool value ) { m_externalTankFlightRefuel = value;  }

	inline double getFuelQty( Tank tank ) const;
	inline double getFuelQtyExternal() const;
	inline double getFuelQtyInternal() const;
	inline double getFuelQtyDelta( Tank tank ) const;
	inline const Vec3& getFuelPos( Tank tank ) const;
	inline Tank getSelectedTank() const;
	inline bool getFuelTransferCaution() const;
	inline bool getFuelBoostCaution() const;
	inline double getTotalCapacity() const;
	inline void setFuelQty( Tank tank, const Vec3& position, double value );
	inline void setInternal( double value );
	inline void setFuelCapacity( double l, double c, double r );
	inline void setFuelPrevious( Tank tank );
	inline void setSelectedTank( Tank tank );
	inline void setFuelDumping(bool dumping);
	inline void setTankPos( Tank tank, const Vec3& pos ) { m_fuelPos[tank] = pos; }

private:
	bool m_unlimited_fuel = false;

	double m_fuel[NUMBER_OF_TANKS] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
	double m_fuelPrevious[NUMBER_OF_TANKS] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
	bool m_fuelEmpty[NUMBER_OF_TANKS] = { false, false, false, false, false };
	bool m_fuelSet[NUMBER_OF_TANKS] = { false, false, false, false, false }; //Has the fuel been loaded on. This is to check for empty tanks.
	//										fuselage wing     l    c   r
	double m_fuelCapacity[NUMBER_OF_TANKS] = { 731.0, 1737.0, 0.0, 0.0, 0.0 }; //changed it to 1737 to match the values from the entry.
	Vec3 m_fuelPos[NUMBER_OF_TANKS] = { Vec3(2.20, 0.0, 0.0), Vec3(-0.82, 0.0, 0.0), Vec3(), Vec3(), Vec3() };

	const bool m_enginePump = true;
	bool m_boostPump = true;
	bool m_boostPumpPressure = false;
	bool m_externalTankPressure = true;
	bool m_mechPumpPressure = true; //is the mechanical pump working
	bool m_wingTankPressure = false; //emergency pressure
	bool m_wingTankBypass = false; //bypass the wing tanks, fueling only the fuselage and external tanks
	bool m_externalTankFlightRefuel = false;

	bool m_hasFuel = true; //this is false is the fuel cannot be delivered or we are out of fuel.
	bool m_dumpingFuel = false;

	bool m_fuelTransferCaution = false;

	double m_fuelInLines = c_fuelInLines;

	static constexpr double leak_rate = 10.0;
	std::function<void(DamageObject&,double)> on_damage_wing = []( DamageObject& object, double integrity )
	{
		const double amount_over = DamageProcessor::GetDamageProcessor().Random() - integrity;
		if ( amount_over > 0.0 )
		{
			object.SetIntegrity( object.GetIntegrity() - amount_over );
			LOG_DAMAGE( "New Leak in: %s, delta=%lf, rate=%lf\n", object.GetName().c_str(), amount_over, object.GetDamage() * leak_rate );
		}
	};

	std::function<void( DamageObject&, double )> on_damage_fuselage = []( DamageObject& object, double integrity )
	{
		if ( integrity < object.GetIntegrity() && DamageProcessor::GetDamageProcessor().Random() < 0.1 )
		{
			object.SetIntegrity( integrity );
			LOG_DAMAGE( "New Leak in: %s, rate=%lf\n", object.GetName().c_str(), object.GetDamage() * leak_rate );
		}
	};

	std::shared_ptr<DamageObject> m_centre_tank_damage = DamageProcessor::MakeDamageObjectMultiple( "Centre Tank", {
		DamageCell::FUSELAGE_LEFT_SIDE,
	    DamageCell::FUSELAGE_RIGHT_SIDE,
		DamageCell::FUSELAGE_BOTTOM
	}, on_damage_fuselage );

	
	std::shared_ptr<DamageObject> m_wing_tank_damage = DamageProcessor::MakeDamageObjectMultiple( "Wing Tank", {
		DamageCell::FUSELAGE_BOTTOM,
		DamageCell::WING_L_IN,
		DamageCell::WING_R_IN,
		DamageCell::WING_L_CENTER,
		DamageCell::WING_R_CENTER,
		}, on_damage_wing );

	std::shared_ptr<DamageObject> m_boost_pump_damage = DamageProcessor::MakeDamageObjectMultiple( "Boost Pump", {
	    DamageCell::FUSELAGE_LEFT_SIDE,
		DamageCell::FUSELAGE_RIGHT_SIDE,
		DamageCell::FUSELAGE_BOTTOM
	}, []( DamageObject& object, double integrity ) {
			if ( integrity < 0.9 && DamageProcessor::GetDamageProcessor().Random() <= 0.3 )
			{
				object.SetIntegrity( 0.0 );
			}
	} );

	std::shared_ptr<DamageObject> m_wing_pump_damage = DamageProcessor::MakeDamageObject( "Wing Pump", DamageCell::FUSELAGE_BOTTOM, 
		[]( DamageObject& object, double integrity ) {
	    if ( integrity < 0.9 && DamageProcessor::GetDamageProcessor().Random() <= 0.4 )
	    {
			object.SetIntegrity( 0.0 );
	    }
	} );

	Tank m_selectedTank = TANK_FUSELAGE;

	Scooter::Engine2& m_engine;
	Scooter::AircraftState& m_state;
};

void FuelSystem2::setUnlimitedFuel( bool state )
{
	m_unlimited_fuel = state;
}

void FuelSystem2::setBoostPumpPower( bool power )
{
	m_boostPump = power;
}

void FuelSystem2::setExternalTankPressure( bool pressure )
{
	m_externalTankPressure = pressure;
}

void FuelSystem2::setMechPumpPressure( bool pressure )
{
	m_mechPumpPressure = pressure;
}

void FuelSystem2::setWingTankPressure( bool pressure )
{
	m_wingTankPressure = pressure;
}

void FuelSystem2::setWingTankBypass( bool bypass )
{
	m_wingTankBypass = bypass;
}

void FuelSystem2::setFuelQty( Tank tank, const Vec3& position, double value )
{
	m_fuelSet[tank] = true; //This tank has just been added.
	m_fuel[tank] = value;
	m_fuelPos[tank] = position;
}

void FuelSystem2::setFuelPrevious( Tank tank )
{
	m_fuelPrevious[tank] = m_fuel[tank];
}

void FuelSystem2::setInternal( double value )
{
	if ( value <= m_fuelCapacity[TANK_FUSELAGE] )
	{
		m_fuel[TANK_FUSELAGE] = value;
		m_fuel[TANK_WING] = 0.0;
	}
	else
	{
		m_fuel[TANK_FUSELAGE] = m_fuelCapacity[TANK_FUSELAGE];
		value -= m_fuel[TANK_FUSELAGE];

		//assert( value <= m_fuelCapacity[TANK_WING] );

		m_fuel[TANK_WING] = std::min( value, m_fuelCapacity[TANK_WING] );
	}
}

void FuelSystem2::setFuelCapacity( double l, double c, double r )
{
	m_fuelEmpty[TANK_EXTERNAL_LEFT] = l < 0.0;
	m_fuelEmpty[TANK_EXTERNAL_CENTRE] = c < 0.0;
	m_fuelEmpty[TANK_EXTERNAL_RIGHT] = r < 0.0;

	// Check each of the external tanks for negative fuel capacity.
	// This means it is an empty tank.
	// Empty tanks need to have their fuel removed. They don't start empty so DCS
	// knows how much fuel the aircraft should have when fully fueled (taking fuel from tanker).
	// If the fuel has just been set then we need to jump into action to remove the fuel from the
	// tank if it is an empty tank. We then need to make sure this doesn't happen again so set the fuelSet
	// to false for this specific tank.
	if ( m_fuelSet[TANK_EXTERNAL_LEFT] && l < 0.0 )
	{
		m_fuel[TANK_EXTERNAL_LEFT] = 0.0;
		m_fuelSet[TANK_EXTERNAL_LEFT] = false;
	}

	if ( m_fuelSet[TANK_EXTERNAL_CENTRE] && c < 0.0 )
	{
		m_fuel[TANK_EXTERNAL_CENTRE] = 0.0;
		m_fuelSet[TANK_EXTERNAL_CENTRE] = false;
	}

	if ( m_fuelSet[TANK_EXTERNAL_RIGHT] && r < 0.0 )
	{
		m_fuel[TANK_EXTERNAL_RIGHT] = 0.0;
		m_fuelSet[TANK_EXTERNAL_RIGHT] = false;
	}
		
	m_fuelCapacity[TANK_EXTERNAL_LEFT] = abs(l);
	m_fuelCapacity[TANK_EXTERNAL_CENTRE] = abs(c);
	m_fuelCapacity[TANK_EXTERNAL_RIGHT] = abs(r);
}

void FuelSystem2::setSelectedTank( Tank tank )
{
	m_selectedTank = tank;
}

void FuelSystem2::setFuelDumping( bool dumping )
{
	m_dumpingFuel = dumping;
}

bool FuelSystem2::getFuelTransferCaution() const
{
	return m_fuelTransferCaution;
}

bool FuelSystem2::getFuelBoostCaution() const
{
	return ! m_boostPumpPressure;
}

double FuelSystem2::getFuelQtyDelta( Tank tank ) const
{
	return m_fuel[tank] - m_fuelPrevious[tank];
}

double FuelSystem2::getFuelQty( Tank tank ) const
{
	return m_fuel[tank];
}

double FuelSystem2::getFuelQtyExternal() const
{
	return m_fuel[TANK_EXTERNAL_CENTRE] + m_fuel[TANK_EXTERNAL_LEFT] + m_fuel[TANK_EXTERNAL_RIGHT];
}

double FuelSystem2::getFuelQtyInternal() const
{
	return m_fuel[TANK_FUSELAGE] + m_fuel[TANK_WING];
}

const Vec3& FuelSystem2::getFuelPos( Tank tank ) const
{
	return m_fuelPos[tank];
}

FuelSystem2::Tank FuelSystem2::getSelectedTank() const
{
	return m_selectedTank;
}

double FuelSystem2::getTotalCapacity() const
{
	double total = 0.0;
	for ( int i = 0; i < NUMBER_OF_TANKS; i++ )
	{
		total += m_fuelCapacity[i];
	}

	total += 1.0;

	return total;
}

bool FuelSystem2::hasFuel() const
{
	return m_hasFuel;
}

bool FuelSystem2::externalFull() const
{
	return m_fuel[TANK_EXTERNAL_LEFT] == m_fuelCapacity[TANK_EXTERNAL_LEFT] &&
		   m_fuel[TANK_EXTERNAL_CENTRE] == m_fuelCapacity[TANK_EXTERNAL_CENTRE] &&
		   m_fuel[TANK_EXTERNAL_RIGHT] == m_fuelCapacity[TANK_EXTERNAL_RIGHT];
}

void FuelSystem2::updateMechPumpPressure()
{
	//Rough approximation for the pump pressure driven from the engine, in psi because who cares.
	m_mechPumpPressure = 4.0 * m_engine.getRPMNorm() * m_engine.getRPMNorm();
}

double FuelSystem2::transferRateFactor()
{
	return clamp( 2.0 * m_engine.getRPMNorm() * m_engine.getRPMNorm(), 0.0, 1.0 );
}

double FuelSystem2::transferFuel( Tank from, Tank to, double dm )
{
	double desiredTransfer = dm;

	//15 kg minimum usable should be tank specific but it's not that different.
	double remainingFrom = m_fuel[from] - 15.0;
	//Check there is enough fuel to take.
	if ( remainingFrom < dm )
		dm = std::max( remainingFrom, 0.0 );

	//Check there is enough room in the to tank.
	double spaceInTo = m_fuelCapacity[to] - m_fuel[to];
	if ( spaceInTo < dm )
		dm = std::max( spaceInTo, 0.0 );

	//Actually transfer the fuel
	m_fuel[from] -= dm;
	m_fuel[to] += dm;

	return desiredTransfer - dm;
}

double FuelSystem2::addFuelToTank( Tank tank, double dm, double min )
{
	double desiredTransfer = dm;

	double remainingFuel = m_fuel[tank] - min;
	double remainingSpace = m_fuelCapacity[tank] - m_fuel[tank];

	if ( dm < 0.0 && remainingFuel + dm < 0.0 )
		dm = std::min( -remainingFuel, 0.0 );

	if ( dm > 0.0 && remainingSpace < dm )
		dm = std::max( remainingSpace, 0.0 );

	m_fuel[tank] += dm;

	return desiredTransfer - dm;
}

} //end scooter namespace
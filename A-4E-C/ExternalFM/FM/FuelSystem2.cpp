#include "FuelSystem2.h"
#include <Common/Commands.h>
#include <stdio.h>
namespace Scooter
{

FuelSystem2::FuelSystem2( Scooter::Engine2& engine, Scooter::AircraftState& state ) :
	m_engine( engine ),
	m_state( state )
{

}

void FuelSystem2::zeroInit()
{

}

void FuelSystem2::coldInit()
{
	zeroInit();
}

void FuelSystem2::hotInit()
{
	zeroInit();
}

void FuelSystem2::airborneInit()
{
	zeroInit();
}

void FuelSystem2::drawFuel( double dm )
{

}

//Return true if we handled an input. This is to make any other
//device input processing orthogonal to each device, to prevent
//needless input processing.
bool FuelSystem2::handleInput( int command, float value )
{
	switch ( command )
	{
	case DEVICE_COMMANDS_ENGINE_WING_FUEL_SW:
		m_dumpingFuel = false;
		m_wingTankPressure = false;

		if ( value == 1.0 )
			m_dumpingFuel = true;
		else if ( value == -1.0 )
			m_wingTankPressure = true;

		return true;
	case DEVICE_COMMANDS_ENGINE_DROP_TANKS_SW:
		m_externalTankPressure = true;
		m_externalTankFlightRefuel = false;

		if ( value == 1.0 )
			m_externalTankPressure = false;
		else if ( value == -1.0 )
		{
			m_externalTankFlightRefuel = true;
			m_externalTankPressure = false;
		}

		return true;
	case DEVICE_COMMANDS_FUEL_TRANSFER_BYPASS:
		if ( value == 1.0 )
			m_wingTankBypass = true;
		else
			m_wingTankBypass = false;

		return true;
	}

	return false;
}

void FuelSystem2::addFuel( double dm, bool wingFirst )
{
	printf( "Add Fuel: %lf, Wing First? %d\n", dm, wingFirst );

	//If adding fuel add it before wing tanks.
	if ( dm > 0.0 && ! wingFirst )
		dm = addFuelToTank( TANK_FUSELAGE, dm );

	printf( "dm after fuse: %lf\n", dm );
	//If the wing tank bypass switch is enabled we
	//refuel the external tanks instead.
	if ( m_externalTankFlightRefuel )
	{
		int externalTanks = 0;
		for ( int i = TANK_EXTERNAL_LEFT; i < NUMBER_OF_TANKS; i++ )
		{
			externalTanks += m_fuelCapacity[i] > 15.0;
		}

		double fracDM = dm / (double)externalTanks;


		if ( externalTanks > 0 )
		{
			dm = 0.0;

			for ( int i = TANK_EXTERNAL_LEFT; i < NUMBER_OF_TANKS; i++ )
			{
				if ( m_fuelCapacity[i] > 15.0 )
					dm += addFuelToTank( (Tank)i, fracDM );
			}
		}
	}

	printf( "dm after ext: %lf\n", dm );
	
	if ( ! m_wingTankBypass ) //Bypass is not enabled so refuel the wing tank.
	{
		dm = addFuelToTank( TANK_WING, dm );
	}

	printf( "dm after wing: %lf\n", dm );

	//If removing fuel remove it from the wing tanks first.
	if ( dm < 0.0 || wingFirst )
		dm = addFuelToTank( TANK_FUSELAGE, dm );

	printf( "dm after fuse/all: %lf\n", dm );
}

void FuelSystem2::update( double dt )
{
	if(m_unlimited_fuel)
	{
		m_boostPumpPressure = true; //Cut the Fuel Boost light
		return;
	}
	//The factor from the engine for transfer since all transfer relies on bleed,
	//either directly to pressurise the tank or to spin a turbopump.
	double rateFactor = transferRateFactor();

	double dm = m_engine.getFuelFlow() * dt;

	double enginePower = m_engine.getRPMNorm() > 0.40;

	//Draw from the Fuselage Tank to the engine, minimum usable fuel.
	if ( m_fuel[TANK_FUSELAGE] > 15.0 && m_enginePump )
	{
		if ( dm > 0.0 )
			m_fuel[TANK_FUSELAGE] -= dm;

		m_hasFuel = true;
	}
	else
	{
		m_hasFuel = false;
	}
	

	if ( m_boostPump && m_boost_pump_damage->GetIntegrity() > 0.0 )
	{
		m_engine.setMaxDeliverableFuelFlowFraction( 1.0 ); //we can deliver as much fuel as we so please.

		//As far as I can tell from the manual this takes longer for flamout
		//for 0.5 > ff > -0.5
		if ( m_state.getGForce() < 0.5 )
		{
			if ( m_state.getGForce() > -0.5 )
				m_fuelInLines -= dm / 3.0;
			else
				m_fuelInLines -= dm;
		}
		else
		{
			m_fuelInLines += dt * c_fuelFlowMax;
		}

		m_fuelInLines = clamp( m_fuelInLines, 0.0, c_fuelInLines );

		if ( m_fuelInLines < 1.0 )
		{
			m_boostPumpPressure = false;
			if ( m_fuelInLines < 0.001 )
				m_hasFuel = false;
		}
		else
			m_boostPumpPressure = true;
	}
	else
	{
		m_boostPumpPressure = false;
		double weight = (-m_state.getPressure() + c_lowFuelFlowPressure) / (c_lowFuelFlowPressure - c_lowFuelFlowPressure50Percent);
		//Just a total guess of about 40% fuel flow at 35kft.
		double maxDeliverable = clamp(lerpWeight( 1.0, 0.4, weight ), 0.0, 1.0);
		//printf( "Weight %lf, Max Deliverable %lf\n", weight, maxDeliverable );
		m_engine.setMaxDeliverableFuelFlowFraction( maxDeliverable );

		//printf( "g: %lf\n", m_state.getGForce() );
		//Less than 0.5 g cut the fuel since we have no boost pump, it's entirely gravity fed.
		if ( m_state.getGForce() < 0.5 )
			m_hasFuel = false;
	}

	m_engine.setHasFuel( m_hasFuel );

	//Divide by two so that at 70% RPM it has 100% transfer rate.
	double wingTransferRate = m_mechPumpPressure && m_wing_pump_damage->GetIntegrity() > 0.0 ? rateFactor * c_fuelTransferRateWingToFuse : 0.0;

	//Emergency Fuel Transfer
	// Only can transfer if there aren't holes
	if ( m_wingTankPressure && m_wing_tank_damage->GetIntegrity() > 0.5 )
		wingTransferRate += c_fuelTransferRateWingToFuseEmergency * rateFactor;

	if ( ! enginePower )
		wingTransferRate = 0.0;

	if ( wingTransferRate < 1.8 || m_fuel[TANK_WING] <= 15.0 )
		m_fuelTransferCaution = true;
	else
		m_fuelTransferCaution = false;

	wingTransferRate *= dt;

	transferFuel( TANK_WING, TANK_FUSELAGE, wingTransferRate );

	if ( m_dumpingFuel )
		addFuelToTank( TANK_WING, -c_fuelDumpRate * dt, 15.0 );


	if ( m_centre_tank_damage->GetIntegrity() < 1.0 )
	{	
		addFuelToTank( TANK_FUSELAGE, -m_centre_tank_damage->GetDamage() * leak_rate * dt, 15.0 );
	}

	if ( m_wing_tank_damage->GetIntegrity() < 1.0 )
	{
		addFuelToTank( TANK_WING, -m_wing_tank_damage->GetDamage() * leak_rate * dt, 15.0 );
	}


	int tankToTransfer = m_wingTankBypass ? TANK_FUSELAGE : TANK_WING;

	//External tanks being pressurised.
	if ( m_externalTankPressure && enginePower )
	{
		double externWingRate = rateFactor * c_fuelTransferRateExternWingToWing * dt;
		double externCentreRate = rateFactor * c_fuelTransferRateExternCentreToWing * dt;

		double transferAmount = 0.0;
		transferAmount += m_fuelCapacity[TANK_EXTERNAL_CENTRE] > 15.0 ? externCentreRate : 0.0;
		transferAmount += m_fuelCapacity[TANK_EXTERNAL_LEFT] > 15.0 ? externWingRate : 0.0;
		transferAmount += m_fuelCapacity[TANK_EXTERNAL_RIGHT] > 15.0 ? externWingRate : 0.0;

		if ( transferAmount <= m_fuelCapacity[tankToTransfer] - m_fuel[tankToTransfer] )
		{
			transferFuel( TANK_EXTERNAL_CENTRE, (FuelSystem2::Tank)tankToTransfer, externCentreRate );
			transferFuel( TANK_EXTERNAL_LEFT, (FuelSystem2::Tank)tankToTransfer, externWingRate );
			transferFuel( TANK_EXTERNAL_RIGHT, (FuelSystem2::Tank)tankToTransfer, externWingRate );
		}
		else
		{
			//Probably should transfer some fuel here but we can just avoid the problem by waiting for the next frame.
		}
	}

	//printf( "Fus: %lf, Wing: %lf, Ex L: %lf, Ex C: %lf, Ex R: %lf\n", m_fuel[0], m_fuel[1], m_fuel[2], m_fuel[3], m_fuel[4] );
}

}//end scooter namespace

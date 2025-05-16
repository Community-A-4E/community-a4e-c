#pragma once
#ifndef INTERFACE_H
#define INTERFACE_H
//=========================================================================//
//
//		FILE NAME	: Interface.h
//		AUTHOR		: Joshua Nelson
//		DATE		: June 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Class for handling interface between lua and C/C++.
//						See equivelent file for lua EFM_Data_Bus.lua.
//
//================================ Includes ===============================//

#include <stdlib.h>
#include <stdio.h>
#include "../include/Cockpit/ccParametersAPI.h"
#include <Common/Vec3.h>
#include <Common/Globals.h>

//=========================================================================//

extern "C"
{
	void _set_radio(void* ptr, bool on);
	bool _get_radio(void* ptr);
	bool _get_intercom(void* ptr);
	bool _is_on_intercom(void* ptr, void* fooPtr);
	void _switch_radio(void* ptr, void* fnc);
	int _get_gun_shells(void* ptr, void* fnc);
	bool _ext_is_on(void* ptr, void* fnc);

	void _connect_radio_power( void* radio, void* elec, void* fnc );
	void _set_radio_power( void* radio, bool value, void* fnc );
}

namespace Scooter
{//namespace begin

class ParameterInterface
{
public:
	ParameterInterface( cockpit_param_api api ):
	    m_api(api)
	{
		Init();
	}

	ParameterInterface()
	{
		m_api = ed_get_cockpit_param_api();
		Init();
	}

	void Init()
	{
		m_RPM					= m_api.pfn_ed_cockpit_get_parameter_handle("RPM");

		m_noseGear				= m_api.pfn_ed_cockpit_get_parameter_handle("FM_GEAR_NOSE");
		m_leftGear				= m_api.pfn_ed_cockpit_get_parameter_handle("FM_GEAR_LEFT");
		m_rightGear				= m_api.pfn_ed_cockpit_get_parameter_handle("FM_GEAR_RIGHT");

		m_flaps					= m_api.pfn_ed_cockpit_get_parameter_handle("FM_FLAPS");
		m_airbrakes				= m_api.pfn_ed_cockpit_get_parameter_handle("FM_BRAKES");
		m_spoiler				= m_api.pfn_ed_cockpit_get_parameter_handle("FM_SPOILERS");

		m_test					= m_api.pfn_ed_cockpit_get_parameter_handle("TEST_TEST");
		m_throttlePosition		= m_api.pfn_ed_cockpit_get_parameter_handle("FM_THROTTLE_POSITION");

		m_engineThrottlePosition = m_api.pfn_ed_cockpit_get_parameter_handle("FM_ENGINE_THROTTLE_POSITION");
		m_engineIgnition		= m_api.pfn_ed_cockpit_get_parameter_handle("FM_IGNITION");
		m_engineBleedAir		= m_api.pfn_ed_cockpit_get_parameter_handle("FM_BLEED_AIR");

		m_stickPitch			= m_api.pfn_ed_cockpit_get_parameter_handle("STICK_PITCH");
		m_stickRoll				= m_api.pfn_ed_cockpit_get_parameter_handle("STICK_ROLL");
		m_rudderPedals			= m_api.pfn_ed_cockpit_get_parameter_handle("RUDDER_PEDALS");
		m_leftBrakePedal		= m_api.pfn_ed_cockpit_get_parameter_handle("LEFT_BRAKE_PEDAL");
		m_rightBrakePedal		= m_api.pfn_ed_cockpit_get_parameter_handle("RIGHT_BRAKE_PEDAL");

		m_stickInputPitch       = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_STICK_INPUT_PITCH" );
		m_stickInputRoll        = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_STICK_INPUT_ROLL" );

		m_pitchTrim				= m_api.pfn_ed_cockpit_get_parameter_handle("PITCH_TRIM");
		m_rollTrim				= m_api.pfn_ed_cockpit_get_parameter_handle("ROLL_TRIM");
		m_rudderTrim			= m_api.pfn_ed_cockpit_get_parameter_handle("RUDDER_TRIM");

		m_nws					= m_api.pfn_ed_cockpit_get_parameter_handle("FM_NWS");

		m_internalFuel = m_api.pfn_ed_cockpit_get_parameter_handle("FM_INTERNAL_FUEL");
		m_externalFuel = m_api.pfn_ed_cockpit_get_parameter_handle("FM_EXTERNAL_FUEL");

		m_radio                 = m_api.pfn_ed_cockpit_get_parameter_handle("THIS_RADIO_PTR");
		m_elec = m_api.pfn_ed_cockpit_get_parameter_handle( "THIS_ELEC_PTR" );

		m_radioPower = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_RADIO_POWER" );

		m_intercom                 = m_api.pfn_ed_cockpit_get_parameter_handle("THIS_INTERCOM_PTR");
		m_weapon                 = m_api.pfn_ed_cockpit_get_parameter_handle("THIS_WEAPON_PTR");

		m_cockpitShake = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_COCKPIT_SHAKE" );

		m_airspeed = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_AIRSPEED" );

		m_yawDamper = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_YAW_DAMPER" );

		m_beta = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_BETA" );
		m_aoa = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_AOA" );
		m_aoaUnits = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_AOA_UNITS" );

		m_validSolution = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_VALID_SOLUTION" );
		m_setTarget = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_SET_TARGET" );
		m_slantRange = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_SLANT_RANGE" );

		m_radarAltitude = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_RADAR_ALTITUDE" );
		m_gunsightAngle = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_GUNSIGHT_ANGLE" );
		m_targetSet = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_TARGET_SET" );
		m_cp741Power = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_CP741_POWER" );
		m_inRange = m_api.pfn_ed_cockpit_get_parameter_handle( "D_ADVISORY_INRANGE" );

		m_dumpingFuel = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_DUMPING_FUEL" );
		m_avionicsAlive = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_AVIONICS_ALIVE" );

		m_lTankCapacity = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_L_TANK_CAPACITY" );
		m_cTankCapacity = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_C_TANK_CAPACITY" );
		m_rTankCapacity = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_R_TANK_CAPACITY" );

		m_sndCockpitRattle = m_api.pfn_ed_cockpit_get_parameter_handle( "SND_ALWS_COCKPIT_RATTLE" );

		m_leftSlat = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_SLAT_LEFT" );
		m_rightSlat = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_SLAT_RIGHT" );

		m_usingFFB = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_USING_FFB" );

		m_elecPrimaryAC = m_api.pfn_ed_cockpit_get_parameter_handle( "ELEC_PRIMARY_AC_OK" );
		m_elecPrimaryDC = m_api.pfn_ed_cockpit_get_parameter_handle( "ELEC_PRIMARY_DC_OK" );
		m_elecMonitoredAC = m_api.pfn_ed_cockpit_get_parameter_handle( "ELEC_AFT_MON_AC_OK" );
		m_masterTest = m_api.pfn_ed_cockpit_get_parameter_handle( "D_MASTER_TEST" );

		m_fuelTransferCaution = m_api.pfn_ed_cockpit_get_parameter_handle( "D_FUELTRANS_CAUTION" );
		m_fuelBoostCaution = m_api.pfn_ed_cockpit_get_parameter_handle( "D_FUELBOOST_CAUTION" );

		m_gForce = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_GFORCE" );
		m_fuelFlow = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_FUEL_FLOW" );


		m_tcnX = m_api.pfn_ed_cockpit_get_parameter_handle( "API_TCN_X" );
		m_tcnY = m_api.pfn_ed_cockpit_get_parameter_handle( "API_TCN_Y" );
		m_tcnZ = m_api.pfn_ed_cockpit_get_parameter_handle( "API_TCN_Z" );
		m_tcnValid = m_api.pfn_ed_cockpit_get_parameter_handle( "API_TCN_VALID" );
		m_tcnObjectID = m_api.pfn_ed_cockpit_get_parameter_handle( "API_TCN_OBJECT_ID" );
		m_tcnUnitName = m_api.pfn_ed_cockpit_get_parameter_handle( "API_TCN_OBJECT_NAME" );

		m_mclX = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_X" );
		m_mclY = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_Y" );
		m_mclZ = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_Z" );
		m_mclHeading = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_HEADING" );
		m_mclValid = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_VALID" );
		m_mclObjectID = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_OBJECT_ID" );
		m_mclUnitName = m_api.pfn_ed_cockpit_get_parameter_handle( "API_MCL_OBJECT_NAME" );

		m_accelerationX = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_ACCELERATION_X" );
		m_accelerationY = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_ACCELERATION_Y" );
		m_accelerationZ = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_ACCELERATION_Z" );

		m_ADC_TAS = m_api.pfn_ed_cockpit_get_parameter_handle( "ADC_TAS" );
		m_ADC_CAS = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_CAS" );
		m_ADC_ALT = m_api.pfn_ed_cockpit_get_parameter_handle( "ADC_ALT" );
		m_ADC_altSetting = m_api.pfn_ed_cockpit_get_parameter_handle( "ADC_ALT_SETTING" );
		m_ADC_MACH = m_api.pfn_ed_cockpit_get_parameter_handle( "ADC_MACH" );

		m_chocks = m_api.pfn_ed_cockpit_get_parameter_handle( "WHEEL_CHOCKS_STATE" );

		m_averageLoadFactor = m_api.pfn_ed_cockpit_get_parameter_handle( "SND_ALWS_DAMAGE_AIRFRAME_STRESS" );
		m_engineStall = m_api.pfn_ed_cockpit_get_parameter_handle( "SND_INST_ENGINE_STALL" );

		m_disableRadar = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_RADAR_DISABLED" );
		m_wheelBrakeAssist = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_WHEEL_BRAKE_ASSIST" );

		m_autoCatMode = m_api.pfn_ed_cockpit_get_parameter_handle( "FM_CAT_AUTO_MODE" );
		m_egg = m_api.pfn_ed_cockpit_get_parameter_handle( "EGG" );
		m_eggScore = m_api.pfn_ed_cockpit_get_parameter_handle( "EGG_SCORE" );
		m_eggHighScore = m_api.pfn_ed_cockpit_get_parameter_handle( "EGG_HIGH_SCORE" );

		m_skid_l_detector = m_api.pfn_ed_cockpit_get_parameter_handle( "SKID_L_DETECTOR" );
		m_skid_r_detector = m_api.pfn_ed_cockpit_get_parameter_handle( "SKID_R_DETECTOR" );
	}

	cockpit_param_api& api()
	{
		return m_api;
	}

	inline void coldInit()
	{

	}

	inline void hotInit()
	{

	}

	inline void airbornInit()
	{

	}

	inline bool egg()
	{
		return getParamNumber( m_egg ) > 0.5;
	}

	inline void eggScore( int score )
	{
		setParamNumber( m_eggScore, score );
	}

	inline void eggHighScore( int score )
	{
		setParamNumber( m_eggHighScore, score );
	}

	inline void testFnc()
	{
		m_api.pfn_ed_cockpit_set_action_digital(10);
	}

	inline void* getPointer( void* handle )
	{
		char buffer[20];
		void* ptr = NULL;
		getParamString( handle, buffer, 20 );
		printf( "%s\n", buffer );
		//printf( "%s\n", buffer );
		if ( sscanf_s( buffer, "%p.0", &ptr ) )
		{
			uintptr_t iptr = uintptr_t(ptr);
			if ( iptr )
			{
				//0x20 is the offset from the lua virtual
				//function table to the primary virtual function
				//table.
				//                                                           
				//primary table | 16 bytes of data | global context pointer | lua table 
				return (void*)( iptr - 0x20);
			}
		}
		else
		{
			LOG( "Pointer could not be found from string: %s\n", buffer );
		}

		return NULL;
	}

	inline void* getIntercomPointer()
	{
		printf( "Intercom: " );
		return getPointer( m_intercom );
	}

	inline void* getRadioPointer()
	{
		printf( "Radio: " );
		return getPointer( m_radio );
	}

	inline void* getElecPointer()
	{
		printf( "Elec: " );
		return getPointer( m_elec );
	}

	inline void* getWeapPointer()
	{
		printf( "Weapon: " );
		return getPointer( m_weapon );
	}

	inline bool getChocks() const
	{
		return getParamNumber( m_chocks ) > 0.5;
	}

	inline uint32_t getTacanObjectID()
	{
		return (uint32_t)getParamNumber( m_tcnObjectID );
	}

	inline void getTacanObjectName(char* buffer, unsigned int size)
	{
		getParamString( m_tcnUnitName, buffer, size );

		//printf( "%s\n", buffer );
	}

	inline uint32_t getMCLObjectID()
	{
		return (uint32_t)getParamNumber( m_mclObjectID );
	}

	inline void getMCLObjectName( char* buffer, unsigned int size )
	{
		getParamString( m_mclUnitName, buffer, size );

		//printf( "%s\n", buffer );
	}

	inline bool getRadarDisabled()
	{
		return getParamNumber( m_disableRadar ) > 0.5;
	}

	inline bool getCatAutoMode()
	{
		return getParamNumber( m_autoCatMode ) > 0.5;
	}

	inline void SetLSkid( bool skid )
	{
		setParamNumber( m_skid_l_detector, (double)skid );
	}

	inline void SetRSkid( bool skid )
	{
		setParamNumber( m_skid_r_detector, (double)skid );
	}

	inline void setEngineStall( bool stall )
	{
		setParamNumber( m_engineStall, (double)stall );
	}

	inline void ADC_setTAS(double value)
	{
		setParamNumber( m_ADC_TAS, value );
	}

	inline void ADC_setCAS( double value )
	{
		setParamNumber( m_ADC_CAS, value );
	}

	inline void ADC_setAlt( double value )
	{
		setParamNumber( m_ADC_ALT, value );
	}

	inline void ADC_setMeasuredMach( double value )
	{
		setParamNumber( m_ADC_MACH, value );
	}

	inline void setWorldAcceleration( const Vec3& a )
	{
		setParamNumber( m_accelerationX, a.x );
		setParamNumber( m_accelerationY, a.y );
		setParamNumber( m_accelerationZ, a.z );
	}

	inline void setTacanPosition( const Vec3& v )
	{
		setParamNumber( m_tcnX, v.x );
		setParamNumber( m_tcnY, v.y );
		setParamNumber( m_tcnZ, v.z );
	}

	inline void setTacanValid( bool valid )
	{
		setParamNumber( m_tcnValid, (double)valid );
	}

	inline void setMCLPosition( const Vec3& v )
	{
		setParamNumber( m_mclX, v.x );
		setParamNumber( m_mclY, v.y );
		setParamNumber( m_mclZ, v.z );
	}

	inline void setMCLHeading( double heading )
	{
		setParamNumber( m_mclHeading, heading );
	}

	inline void setMCLValid( bool valid )
	{
		setParamNumber( m_mclValid, (double)valid );
	}

	inline void setFuelFlow( double number )
	{
		setParamNumber( m_fuelFlow, number );
	}

	inline void setLeftSlat( double number )
	{
		setParamNumber( m_leftSlat, number );
	}

	inline void setRightSlat( double number )
	{
		setParamNumber( m_rightSlat, number );
	}

	inline void setCockpitRattle( double number )
	{
		setParamNumber( m_sndCockpitRattle, number );
	}

	inline void setInternalFuel(double number)
	{
		setParamNumber(m_internalFuel, number);
	}

	inline void setExternalFuel(double number)
	{
		setParamNumber(m_externalFuel, number);
	}

	inline void setRPM(double number)
	{
		setParamNumber(m_RPM, number);
	}

	inline void setThrottlePosition(double number)
	{
		setParamNumber(m_throttlePosition, number);
	}

	inline void setStickPitch(double number)
	{
		setParamNumber(m_stickPitch, number);
	}

	inline void setStickRoll(double number)
	{
		setParamNumber(m_stickRoll, number);
	}

	inline void setRudderPedals(double number)
	{
		setParamNumber(m_rudderPedals, number);
	}

	inline void setAirspeed( double number )
	{
		setParamNumber( m_airspeed, number );
	}

	inline void setAOA( double number )
	{
		setParamNumber( m_aoa, number );
	}

	inline void setBeta( double number )
	{
		setParamNumber( m_beta, number );
	}

	inline void setAOAUnits( double number )
	{
		setParamNumber( m_aoaUnits, number );
	}

	inline void setValidSolution( bool solution )
	{
		setParamNumber( m_validSolution, (double)solution );
	}

	inline void setTargetSet( bool targetSet )
	{
		setParamNumber( m_targetSet, (double)targetSet );
	}

	inline void setStickInputPitch( double number )
	{
		setParamNumber( m_stickInputPitch, number );
	}

	inline void setStickInputRoll( double number )
	{
		setParamNumber( m_stickInputRoll, number );
	}

	inline void setLeftBrakePedal( double number )
	{
		setParamNumber( m_leftBrakePedal, number );
	}

	inline void setRightBrakePedal( double number )
	{
		setParamNumber( m_rightBrakePedal, number );
	}

	inline void setUsingFFB( bool ffb )
	{
		setParamNumber( m_usingFFB, (double)ffb );
	}

	inline void setInRange( bool inRange )
	{
		if (getMasterTest() == false) {
            setParamNumber(m_inRange, (double)inRange);
        }	
	}

	inline void setFuelTransferCaution( bool caution )
	{
		setParamNumber( m_fuelTransferCaution, (double)caution );
	}

	inline void setFuelBoostCaution( bool caution )
	{
		setParamNumber( m_fuelBoostCaution, (double)caution );
	}

	inline void setLoadFactor( double factor )
	{
		setParamNumber( m_averageLoadFactor, factor );
	}

	inline double getGForce()
	{
		return getParamNumber( m_gForce );
	}

	inline bool getCP741Power()
	{
		return getParamNumber( m_cp741Power ) > 0.5;
	}

	inline bool getElecPrimaryAC()
	{
		return getParamNumber( m_elecPrimaryAC ) > 0.5;
	}

	inline bool getElecPrimaryDC()
	{
		return getParamNumber( m_elecPrimaryDC ) > 0.5;
	}

	inline bool getElecMonitoredAC()
	{
		return getParamNumber( m_elecMonitoredAC ) > 0.5;
	}

	inline bool getMasterTest()
	{
		return getParamNumber( m_masterTest ) > 0.5;
	}

	inline bool getRadioPower()
	{
		return getParamNumber( m_radioPower ) > 0.5;
	}

	inline double getSlantRange()
	{
		return getParamNumber( m_slantRange );
	}

	inline bool getSetTarget()
	{
		return getParamNumber( m_setTarget ) > 0.5;
	}

	inline double getGearNose()
	{
		return getParamNumber(m_noseGear);
	}
	inline double getGearLeft()
	{
		return getParamNumber(m_leftGear);
	}
	inline double getGearRight()
	{
		return getParamNumber(m_rightGear);
	}

	inline double getFlaps()
	{
		return getParamNumber(m_flaps);
	}

	inline double getSpeedBrakes()
	{
		return getParamNumber(m_airbrakes);
	}

	inline double getSpoilers()
	{
		return getParamNumber(m_spoiler);
	}

	inline double getPitchTrim()
	{
		return getParamNumber(m_pitchTrim);
	}

	inline double getRollTrim()
	{
		return getParamNumber(m_rollTrim);
	}

	inline double getRudderTrim()
	{
		return getParamNumber(m_rudderTrim);
	}

	inline double getEngineThrottlePosition()
	{
		return getParamNumber(m_engineThrottlePosition);
	}

	inline double getBleedAir()
	{
		return getParamNumber(m_engineBleedAir);
	}

	inline double getIgnition()
	{
		return getParamNumber(m_engineIgnition);
	}

	inline bool getNWS()
	{
		return getParamNumber(m_nws) > 0.5;
	}

	inline double getCockpitShake()
	{
		return getParamNumber( m_cockpitShake );
	}

	inline double getYawDamper()
	{
		return getParamNumber( m_yawDamper );
	}

	inline double getRadarAltitude()
	{
		return getParamNumber( m_radarAltitude );
	}

	inline double getGunsightAngle()
	{
		return getParamNumber( m_gunsightAngle );
	}

	inline bool getDumpingFuel()
	{
		return getParamNumber( m_dumpingFuel ) > 0.5;
	}

	inline bool getAvionicsAlive()
	{
		return getParamNumber( m_avionicsAlive ) > 0.5;
	}

	inline double getLTankCapacity()
	{
		return getParamNumber( m_lTankCapacity );
	}

	inline double getCTankCapacity()
	{
		return getParamNumber( m_cTankCapacity );
	}

	inline double getRTankCapacity()
	{
		return getParamNumber( m_rTankCapacity );
	}

	inline bool getWheelBrakeAssist()
	{
		return getParamNumber( m_wheelBrakeAssist ) > 0.5;
	}

	inline double getAltSetting()
	{
		return getParamNumber( m_ADC_altSetting );
	}
		 
	void* m_test = NULL;

	inline void setParamNumber( void* ptr, double number )
	{
		m_api.pfn_ed_cockpit_update_parameter_with_number( ptr, number );
	}
	inline double getParamNumber( void* ptr ) const
	{
		double result;
		m_api.pfn_ed_cockpit_parameter_value_to_number( ptr, result, false );
		return result;
	}

private:

	inline void getParamString(void* ptr, char* buffer, unsigned int bufferSize) const
	{
		m_api.pfn_ed_cockpit_parameter_value_to_string(ptr, buffer, bufferSize);
	}

	

	inline void setParamString(void* ptr, const char* string)
	{
		m_api.pfn_ed_cockpit_update_parameter_with_string(ptr, string);
	}


	cockpit_param_api m_api;

	//void* because C isn't a typed language kek
	void* m_RPM = NULL;
	void* m_noseGear = NULL;
	void* m_leftGear = NULL;
	void* m_rightGear = NULL;
	void* m_flaps = NULL;
	void* m_spoiler = NULL;
	void* m_airbrakes = NULL;

	void* m_rudderPedals = NULL;
	void* m_stickRoll = NULL;
	void* m_stickPitch = NULL;
	void* m_throttlePosition = NULL;

	void* m_leftBrakePedal = NULL;
	void* m_rightBrakePedal = NULL;

	void* m_stickInputPitch = NULL;
	void* m_stickInputRoll = NULL;

	void* m_engineThrottlePosition = NULL;
	void* m_engineIgnition = NULL;
	void* m_engineBleedAir = NULL;

	void* m_rollTrim = NULL;
	void* m_pitchTrim = NULL;
	void* m_rudderTrim = NULL;

	void* m_nws = NULL;

	void* m_internalFuel = NULL;
	void* m_externalFuel = NULL;

	void* m_airspeed = NULL;

	//Radio Pointer for the Radio Device.
	void* m_radio = NULL;
	void* m_elec = NULL;
	void* m_intercom = NULL;
	void* m_radioPower = NULL;
	void* m_weapon = NULL;
	void* m_cockpitShake = NULL;

	void* m_yawDamper = NULL;

	void* m_beta = NULL;
	void* m_aoa = NULL;
	void* m_aoaUnits = NULL;

	void* m_setTarget = NULL;
	void* m_validSolution = NULL;
	void* m_slantRange = NULL;
	void* m_cp741Power = NULL;
	void* m_inRange = NULL;

	void* m_radarAltitude = NULL;
	void* m_gunsightAngle = NULL;
	void* m_targetSet = NULL;

	void* m_dumpingFuel = NULL;

	void* m_avionicsAlive = NULL;

	void* m_lTankCapacity = NULL;
	void* m_cTankCapacity = NULL;
	void* m_rTankCapacity = NULL;

	void* m_sndCockpitRattle = NULL;

	void* m_leftSlat = NULL;
	void* m_rightSlat = NULL;

	void* m_usingFFB = NULL;

	//Electrics
	void* m_fuelTransferCaution = NULL;
	void* m_fuelBoostCaution = NULL;

	void* m_elecPrimaryAC = NULL;
	void* m_elecPrimaryDC = NULL;
	void* m_elecMonitoredAC = NULL;

	void* m_masterTest = NULL;

	void* m_gForce = NULL;

	void* m_fuelFlow = NULL;

	void* m_tcnX = NULL;
	void* m_tcnY = NULL;
	void* m_tcnZ = NULL;
	void* m_tcnValid = NULL;
	void* m_tcnObjectID = NULL;
	void* m_tcnUnitName = NULL;

	void* m_mclX = NULL;
	void* m_mclY = NULL;
	void* m_mclZ = NULL;
	void* m_mclHeading = NULL;
	void* m_mclValid = NULL;
	void* m_mclObjectID = NULL;
	void* m_mclUnitName = NULL;

	void* m_accelerationX = NULL;
	void* m_accelerationY = NULL;
	void* m_accelerationZ = NULL;

	//ADC Variables
	void* m_ADC_TAS = NULL;
	void* m_ADC_TASX = NULL;
	void* m_ADC_TASZ = NULL;
	void* m_ADC_ALT = NULL;
	void* m_ADC_altSetting = NULL;
	void* m_ADC_MACH = NULL;

	void* m_chocks = NULL;

	void* m_averageLoadFactor = NULL;

	void* m_ADC_CAS = NULL;

	void* m_engineStall = NULL;

	void* m_disableRadar = NULL;
	void* m_wheelBrakeAssist = NULL;

	void* m_autoCatMode = NULL;

	void* m_egg = NULL;
	void* m_eggScore = NULL;
	void* m_eggHighScore = NULL;

	void* m_skid_l_detector = NULL;
	void* m_skid_r_detector = NULL;

};


}//namepsace end
#endif 

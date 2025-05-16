#pragma once
#include "../include/Cockpit/ccParametersAPI.h"
#include "Interface.h"
#include <stdio.h>

extern "C"
{
	void* _find_vfptr_fnc( void*, intptr_t );
}

namespace Scooter
{

class ILS
{
public:
	ILS(ParameterInterface& inter):
		m_interface(inter)
	{
		m_api = ed_get_cockpit_param_api();
	}

	/*
	ILS + 0x3A8 is one electric switch.
	ILS + 0x520 is another electric switch.

	*/
	void test()
	{
		if ( m_power )
			return;

		void* electrics = m_interface.getElecPointer();

		if ( ! electrics )
			return;

		void*** context = (void***)((intptr_t)m_api.device_array + 0x30);
		
		printf( "Root %p\n", m_api.device_array );
		
		
		if ( ! context )
			return;

		printf( "Context: %p\n", context );

		void** deviceTable = *context;

		if ( !deviceTable )
			return;

		printf( "Device Table: %p\n", context );

		m_device = deviceTable[1];

		if ( ! m_device )
			return;

		printf( "Device: %p\n", m_device );

		
		void* dcWire = m_api.pfn_get_dc_wire( electrics, 1 );
		void* acWire = m_api.pfn_get_ac_wire( electrics, 1 );

		printf( "Wires: %p, %p\n", dcWire, acWire );

		if ( ! dcWire || ! acWire )
			return;

		m_api.pfn_connect_ils_electric( m_device, dcWire, acWire );
		printf( "Electric Connected\n" );


		m_switch1 = (void*)((intptr_t)m_device + 0x3A8);
		m_switch2 = (void*)((intptr_t)m_device + 0x520);

		printf( "Switch 1: %p, Switch 2: %p\n", m_switch1, m_switch2 );

		fnc_setPower = (PFN_SET_ELEC_POWER)_find_vfptr_fnc( m_switch1, 0xF8 );

		printf( "Set Power FNC: %p\n", fnc_setPower );
		
		fnc_setPower( m_switch1, true );
		printf( "Set Switch 1 on\n" );


		fnc_setPower( m_switch2, true );
		printf( "Set Switch 2 on\n" );

		printf( "Is ILS On? %s\n", m_api.pfn_is_ils_on( m_device ) ? "YES" : "NO" );

		m_power = m_api.pfn_is_ils_on( m_device );
		//m_api.pfn_set_ils_on( m_device, true );
		m_api.pfn_set_MHz( m_device, 15415 );
		m_api.pfn_set_KHz( m_device, 000 );
		
		//printf( "ILS: %p\n", m_device );
	}

	void update()
	{
		if ( ! m_power )
			return;
		//mhz++;
		

		

		double gs = m_api.pfn_get_gs( m_device );
		double loc = m_api.pfn_get_loc( m_device );

		//if ( gs != 0.0 || loc != 0.0 )
		printf( "GS: %lf, LOC %lf\n", gs, loc );

		//printf( "GS: %lf, LOC: %lf\n", gs, loc );
	}

private:

	int mhz = 0;

	bool m_power = false;
	void* m_device = NULL;
	void* m_switch1 = NULL;
	void* m_switch2 = NULL;
	ParameterInterface& m_interface;
	cockpit_param_api m_api;
	PFN_SET_ELEC_POWER fnc_setPower;
};

}//end namespace
#pragma once
#ifndef TACAN_H
#define TACAN_H
//=========================================================================//
//
//		FILE NAME	: Tacan.h
//		AUTHOR		: Joshua Nelson
//		DATE		: January 2021
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Tacan trickery.
//
//================================ Includes ===============================//
#include "Interface.h"
#include "../include/Cockpit/ccParametersAPI.h"
#include <stdlib.h>
//=========================================================================//

namespace Scooter
{

	class Tacan
	{
	public:
		Tacan( ParameterInterface& inter );
		~Tacan();

		void setup( void* radio, void* electricalSystem, void* intercom );
		void update();
		void cleanup();
		inline void setPower( bool power );
		inline bool isSetup();
		inline void toggleRadioMenu();

	private:
		void* m_radio = NULL;
		void* m_intercom = NULL;
		bool m_setup = false;
		bool m_on = -1;

		cockpit_param_api m_api;
		ParameterInterface& m_interface;
		PFN_SET_ELEC_POWER fnc_setElecPower = NULL;
	};

	void Tacan::setPower( bool power )
	{
		if ( power == m_on )
			return;

		if ( fnc_setElecPower && m_radio )
		{
			fnc_setElecPower( m_radio, power );
			m_on = power;
		}
	}

	bool Tacan::isSetup()
	{
		return m_setup;
	}

	void Tacan::toggleRadioMenu()
	{
		if ( m_intercom )
		{
			m_api.pfn_push_to_talk( m_intercom, true );
			//printf( "Toggle Radio\n" );
		}
	}


}//end namespace

#endif //RADIO_H


#pragma once
//=========================================================================//
//
//		FILE NAME	: LuaVM.h
//		AUTHOR		: Joshua Nelson
//		DATE		: Feb 2021
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Lua helper, for config files.
//
//================================ Includes ===============================//
#include "../include/Cockpit/ccParametersAPI.h"
#include "../include/FM/wHumanCustomPhysicsAPI.h"
#include <vector>
#include <Common/Maths.h>
#include "LERX.h"

extern "C"
{
#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"
}

#pragma comment(lib, "lua.lib")

class LuaVM
{
public:
	LuaVM();
	~LuaVM();

	lua_State* L();
	
	bool dofile( const char* path );
	bool getGlobalNumber( const char* name, double& number );
	const char* getGlobalString( const char* name );
	bool getGlobalTableNumber( const char* table, const char* key, float& result );
	void getSplines( const char* name, std::vector<LERX>& vec );
	bool outputCommands( const char* name );
	bool outputDevices( const char* name );

private:

	bool writeTableKeysToFile( FILE* file, const char* name );

	void getSpline( std::vector<LERX_vortex_spline_point>& vec );
	bool getTableVec3(const char* name, float* vec);
	bool processSplinePoint( LERX_vortex_spline_point& point );

	bool luaOkay( const int status );
	bool getTableValue( const char* key );
	bool getTableNumber( const char* key, float& value );

	lua_State* m_state = NULL;

	cockpit_param_api m_api;
};
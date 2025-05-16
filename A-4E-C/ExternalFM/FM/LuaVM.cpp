//=========================================================================//
//
//		FILE NAME	: LuaVM.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: Feb 2021
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Lua helper, for config files.
//
//================================ Includes ===============================//
#include "LuaVM.h"
#include <stdio.h>
//=========================================================================//

LuaVM::LuaVM()
{
	m_state = luaL_newstate();
	luaL_openlibs( m_state );
	//m_api = ed_get_cockpit_param_api();

	//m_state = m_api.pfn_create_lua_vm();
}

LuaVM::~LuaVM()
{
	lua_close( m_state );
	//m_api.pfn_destroy_lua_vm( m_state );
	m_state = NULL;
}

bool LuaVM::getGlobalNumber(const char* name, double& number )
{
	lua_getglobal( m_state, name );
	if ( lua_isnumber( m_state, -1 ) )
	{
		number = lua_tonumber(m_state, -1);
		return true;
	}
	lua_pop( m_state, 1 );

	number = 0.0;
	return false;
}

const char* LuaVM::getGlobalString( const char* name )
{
	lua_getglobal( m_state, name );
	if ( lua_isstring( m_state, -1 ) )
	{
		return lua_tostring( m_state, -1 );
	}
	lua_pop( m_state, 1 );
	return "";
}

bool LuaVM::getGlobalTableNumber( const char* table, const char* key, float& result )
{
	lua_getglobal( m_state, table );

	return getTableNumber( key, result );
}

bool LuaVM::getTableValue( const char* key )
{
	if ( lua_istable( m_state, -1 ) )
	{
		lua_pushstring( m_state, key );
		lua_gettable( m_state, -2 );
		return true;
	}

	return false;
}

bool LuaVM::getTableNumber( const char* key, float& value )
{

	if ( ! getTableValue( key ) || ! lua_isnumber( m_state, -1 ) )
	{
		lua_pop( m_state, 1 );
		return false;
	}

	value = float(lua_tonumber( m_state, -1 ));
	lua_pop( m_state, 1 );
	return true;
}

bool LuaVM::dofile( const char* path )
{
	return luaOkay( luaL_dofile( m_state, path ) );
}

bool LuaVM::luaOkay( const int status )
{
	if ( status !=  0 )
	{
		printf( "%s\n", lua_tostring( m_state, -1 ) );
		return false;
	}

	return true;
}

void LuaVM::getSplines( const char* name, std::vector<LERX>& vec )
{
	lua_getglobal( m_state, name );

	if ( ! lua_istable( m_state, -1 ) )
	{
		return;
	}

	vec.clear();

	int tableIdx = lua_gettop( m_state );
	lua_pushnil( m_state );

	while ( lua_next( m_state, tableIdx ) )
	{
		std::vector<LERX_vortex_spline_point> spline;

		getSpline( spline );

		if ( spline.size() )
		{
			vec.push_back( LERX(spline) );
		}
		
		lua_pop( m_state, 1 );
	}
}

void LuaVM::getSpline( std::vector<LERX_vortex_spline_point>& vec )
{
	if ( ! lua_istable( m_state, -1 ) )
	{
		return;
	}

	int tableIdx = lua_gettop( m_state );

	lua_pushnil( m_state );

	while ( lua_next( m_state, tableIdx ) )
	{
		LERX_vortex_spline_point point;

		if ( processSplinePoint( point ) )
		{
			vec.push_back( point );
		}

		lua_pop( m_state , 1 );
	}
}

bool LuaVM::getTableVec3( const char* name, float* vec )
{
	if ( ! getTableValue( name ) )
	{
		return false;
	}

	if ( ! lua_istable( m_state, -1 ) )
	{
		return false;
	}

	int tableIdx = lua_gettop( m_state );

	lua_pushnil( m_state );

	for ( int i = 0; i < 3 && lua_next( m_state, tableIdx ); i++ )
	{
		if ( ! lua_isnumber( m_state, -1 ) )
			return false;

		vec[i] = (float)lua_tonumber( m_state, -1 );
		lua_pop( m_state, 1 );
	}
	
	lua_pop( m_state, 2 );

	return true;
}

bool LuaVM::processSplinePoint( LERX_vortex_spline_point& point )
{
	if ( ! getTableVec3( "pos", point.pos ) )
		return false;

	if ( ! getTableVec3( "vel", point.vel ) )
		return false;

	if ( ! getTableNumber("radius", point.radius ) )
		return false;

	if ( ! getTableNumber( "opacity", point.opacity ) )
		return false;
	
	return true;
}

static void toUpper( char* str, size_t size, const char* category, const char* command )
{
	if ( ! category || ! command )
		return;

	int i;
	for ( i = 0; category[i]; i++ )
	{
		str[i] = toupper( category[i] );
	}

	str[i++] = '_';
	
	int j;
	for ( j = 0; command[j]; j++ )
	{
		str[j + i] = toupper( command[j] );
	}

	str[i + j] = 0;
}

bool LuaVM::writeTableKeysToFile( FILE* file, const char* name )
{
	lua_getglobal( m_state, name );

	if ( ! lua_istable( m_state, -1 ) )
	{
		return false;
	}

	int tableIdx = lua_gettop( m_state );

	lua_pushnil( m_state );

	char line[200];

	while ( lua_next( m_state, tableIdx ) )
	{

		if ( ! lua_isstring( m_state, -2 ) || ! lua_isnumber( m_state, -1 ) )
		{
			continue;
		}

		const char* str = lua_tostring( m_state, -2 );
		int command = (int)lua_tonumber( m_state, -1 );
		toUpper( line, 200, name, str );

		fprintf( file, "%s = %d,\n", line, command );

		lua_pop( m_state, 1 );
	}

	return true;
}

//bool LuaVM::outputCommands( const char* name )
//{
//
//	FILE* file = fopen( name, "w+" );
//
//	if ( ! file )
//		return false;
//
//	fprintf( file,  "#pragma once\nenum Command\n{\n" );
//
//	if ( ! writeTableKeysToFile( file, "Keys" ) )
//	{
//		printf( "ERROR: Couldn't get Keys table." );
//	}
//
//	if ( ! writeTableKeysToFile( file, "device_commands" ) )
//	{
//		printf( "ERROR: Couldn't get device_commands table." );
//	}
//
//	fprintf( file, "};\n" );
//
//	fclose( file );
//
//	return true;
//}
//
//bool LuaVM::outputDevices( const char* name )
//{
//	FILE* file = fopen( name, "w+" );
//
//	if ( ! file )
//		return false;
//
//	fprintf( file, "#pragma once\nenum Devices\n{\n" );
//	if ( ! writeTableKeysToFile( file, "devices" ) )
//	{
//		printf( "ERROR: Couldn't get devices table." );
//	}
//
//	fprintf( file, "};\n" );
//
//	fclose( file );
//
//	return true;
//}
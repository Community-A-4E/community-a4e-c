#include "Scooter.h"

extern "C"
{
#include "lua.h"
#include "lauxlib.h"
}

#include "stdafx.h"



namespace LuaScooter
{

int SetLua(lua_State* L, double value)
{
    lua_pushnumber(L, value);
    return 1;
}

int SetLua(lua_State* L, bool value )
{
    lua_pushboolean(L, value);
    return 1;
}

int SetLua(lua_State* L, const char* value)
{
    lua_pushstring(L, value);
    return 1;
}

#define STATE_GETTER( function_name, member ) { function_name, []( lua_State* L ){ return SetLua(L, member); } }

extern "C" int __declspec(dllexport) luaopen_Scooter( lua_State* L )
{
    lua_newtable( L );

    static const luaL_Reg functions[] = {
        STATE_GETTER( "GetRPMPercent" , s_state->engine.getRPMNorm()*100.0),
        STATE_GETTER( "GetFuelFlow" , s_state->engine.getFuelFlow() ),
        STATE_GETTER( "GetThrottleNorm" , s_state->input.throttleNorm()),
        STATE_GETTER( "GetStickPitch" , s_state->airframe.getElevator()),
        STATE_GETTER( "GetStickRoll" , s_state->input.roll() + s_state->input.rollTrim() ),
        STATE_GETTER( "GetBrakeLeft" , s_state->input.brakeLeft() ),
        STATE_GETTER( "GetBrakeRight" , s_state->input.brakeRight() ),
        STATE_GETTER( "GetStickInputPitch" , s_state->input.pitch() ),
        STATE_GETTER( "GetStickInputRoll" , s_state->input.roll() ),
        STATE_GETTER( "GetRudderInput" , s_state->input.yawAxis().getValue()),
        STATE_GETTER( "GetFuelQtyInternal" , s_state->fuelSystem.getFuelQtyInternal() ),
        STATE_GETTER( "GetFuelQtyExternal" , s_state->fuelSystem.getFuelQtyExternal() ),
        STATE_GETTER( "GetAlpha" , s_state->state.getAOA() ),
        STATE_GETTER( "GetBeta" , s_state->state.getBeta() ),
        STATE_GETTER( "GetAlphaUnits" , rawAOAToUnits(s_state->state.getAOA()) ),
        STATE_GETTER( "GetValidSolution" , s_state->avionics.getComputer().getSolution() ),
        STATE_GETTER( "GetTargetSet" , s_state->avionics.getComputer().getTargetSet() ),
        STATE_GETTER( "GetInRange" , s_state->avionics.getComputer().inRange() ),
        STATE_GETTER( "GetLeftSlat" , s_state->airframe.getSlatLPosition() ),
        STATE_GETTER( "GetRightSlat" , s_state->airframe.getSlatRPosition() ),
        STATE_GETTER( "GetFFBEnabled" , s_state->input.getFFBEnabled() ),
        STATE_GETTER( "GetSkiddingLeft" , s_state->airframe.IsSkiddingLeft() ),
        STATE_GETTER( "GetSkiddingRight" , s_state->airframe.IsSkiddingRight() ),
        STATE_GETTER( "Version" , srcvers ),
        //STATE_GETTER( "" , s_state->interface.getElecPrimaryAC() && (s_state->interface.getMasterTest() || s_state->fuelSystem.getFuelTransferCaution()) ),
        //STATE_GETTER( "" , s_state->interface.getElecPrimaryAC() && (s_state->interface.getMasterTest() || s_state->fuelSystem.getFuelBoostCaution()) ),

        {nullptr,nullptr}
    };

    luaL_register( L, nullptr, functions );
    return 1;
}


}


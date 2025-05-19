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

int SetLua(lua_State* L, Vec3 value)
{
    lua_newtable(L);

    lua_pushnumber(L, value.x);
    lua_setfield(L, -2, "x");

    lua_pushnumber(L, value.y);
    lua_setfield(L, -2, "y");

    lua_pushnumber(L, value.z);
    lua_setfield(L, -2, "z");
    return 1;
}

int ToWorld( lua_State* L )
{
    Vec3 forward = s_state->state.getWorldDirection();
    Vec3 up = s_state->state.getWorldUp();
    Vec3 right = s_state->state.getWorldRight();

    Vec3 v;

    lua_getfield(L, 1, "x");
    v.x = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 1, "y");
    v.y = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 1, "z");
    v.z = lua_tonumber(L, -1);
    lua_pop(L, 1);

    Vec3 transformed_v;
    // matrix mul
    transformed_v.x = forward.x * v.x + up.x * v.y + right.x * v.z;
    transformed_v.y = forward.y * v.x + up.y * v.y + right.y * v.z;
    transformed_v.z = forward.z * v.x + up.z * v.y + right.z * v.z;
    return SetLua(L, transformed_v);
}

int ToLocal( lua_State* L )
{
    Vec3 forward = s_state->state.getWorldDirection();
    Vec3 up = s_state->state.getWorldUp();
    Vec3 right = s_state->state.getWorldRight();

    Vec3 v;

    lua_getfield(L, 1, "x");
    v.x = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 1, "y");
    v.y = lua_tonumber(L, -1);
    lua_pop(L, 1);

    lua_getfield(L, 1, "z");
    v.z = lua_tonumber(L, -1);
    lua_pop(L, 1);

    Vec3 transformed_v;
    // matrix mul

    // fx ux rx
    // fy uy ry
    // fz uz rz

    // transpose
    // fx fy fz
    // ux uy uz
    // rx ry rz
    transformed_v.x = forward.x * v.x + forward.y * v.y + forward.z * v.z;
    transformed_v.y = up.x * v.x + up.y * v.y + up.z * v.z;
    transformed_v.z = right.x * v.x + right.y * v.y + right.z * v.z;
    return SetLua(L, transformed_v);
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
        STATE_GETTER( "GetForward", s_state->state.getWorldDirection() ),
        STATE_GETTER( "GetUp", -s_state->state.getGlobalDownVectorInBody() ),
        STATE_GETTER( "GetRight", cross(s_state->state.getWorldDirection(), -s_state->state.getGlobalDownVectorInBody()) ),
        {"ToLocal", ToLocal},
        {"ToWorld", ToWorld},
        //STATE_GETTER( "" , s_state->interface.getElecPrimaryAC() && (s_state->interface.getMasterTest() || s_state->fuelSystem.getFuelTransferCaution()) ),
        //STATE_GETTER( "" , s_state->interface.getElecPrimaryAC() && (s_state->interface.getMasterTest() || s_state->fuelSystem.getFuelBoostCaution()) ),

        {nullptr,nullptr}
    };

    luaL_register( L, nullptr, functions );
    return 1;
}


}


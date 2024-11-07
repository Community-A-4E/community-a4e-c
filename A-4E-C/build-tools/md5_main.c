#include "lua.h"
#include <Common/md5.h>
#include <stdio.h>
#include <assert.h>

int hash_md5( lua_State* L )
{
    if ( ! lua_isstring(L, 1) )
    {
        lua_pushnil(L);
        return 1;
    }

    size_t length;
    const char* str = lua_tolstring(L, 1, &length);
    MD5_CTX context;
    MD5_Init(&context);
    MD5_Update(&context, str, length);
    
    unsigned char hash[16];
    MD5_Final(hash, &context);

    char str_hash[33]; // 32 + null
    for ( ptrdiff_t i = 0; i < 16; i++ )
    {
        const int err_no = sprintf(str_hash+i*2, "%02hhx", hash[i]);
        assert(err_no);
    }

    lua_pushstring(L, str_hash);
    return 1;
}

int __declspec(dllexport) luaopen_md5( lua_State* L )
{
    lua_newtable( L );
    const int table = lua_gettop(L);

    lua_pushcfunction(L, hash_md5);
    lua_setfield(L, table, "hash");

    return 1;
}
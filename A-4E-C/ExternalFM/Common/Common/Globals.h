#pragma once //globals r bad
#ifndef GLOBALS_H
#define GLOBALS_H
//=========================================================================//
//
//		FILE NAME	: Globals.h
//		AUTHOR		: Joshua Nelson
//		DATE		: June 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Contains all global variables declaration.
//
//================================ Includes ===============================//
#include <stdio.h>
#include <algorithm>
#include "ED_FM_API.h"
//=========================================================================//

#undef max
#undef min

extern FILE* g_log;
extern ED_FM_API int g_safeToRun;
extern bool g_logging;
extern bool g_disableRadio;

//#define DEBUG_CONSOLE

//#define DISPLAY_IMGUI
#ifndef DISPLAY_IMGUI
#define DISABLE_IMGUI
#endif



//Uncomment this to enable logging make sure this is commited with this commented out!!!!!!
#define LOGGING

inline const char* ToNarrow( const wchar_t* string, char* buffer, size_t max_len )
{
    size_t size;
    wcstombs_s( &size, buffer, max_len, string, _TRUNCATE );
    return buffer;
}

void ImGuiLog( const char* c );

static inline char log_buffer[500];
static inline wchar_t wlog_buffer[500];
#ifdef LOGGING
//#define LOG(s, ...) sprintf_s(log_buffer, 500, s, __VA_ARGS__); ImGuiLog(log_buffer)
//#define WLOG(s, ...) swprintf_s(wlog_buffer, 500, s, __VA_ARGS__); ImGuiLog(ToNarrow(wlog_buffer, log_buffer, 500))

#define WLOG( s, ... ) if ( g_log ) fwprintf( g_log, s, __VA_ARGS__ );
#define LOG(s, ...) if ( g_log ) fprintf(g_log, s, __VA_ARGS__);
#else
#define LOG(s, ...) /*nothing*/
#define WLOG(s, ...) /*nothing*/
#endif

#define LOG_BREAK() LOG("===================\n")

#define DAMAGE_LOGGING
#ifdef DAMAGE_LOGGING
#define LOG_DAMAGE(s,...) LOG(s, __VA_ARGS__)
#else
#define LOG_DAMAGE(s,...)
#endif


#endif

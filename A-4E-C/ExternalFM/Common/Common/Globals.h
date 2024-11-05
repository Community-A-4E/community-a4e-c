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
#include "ED_FM_API.h"
//=========================================================================//

#undef max
#undef min

extern FILE* g_log;
extern ED_FM_API int g_safeToRun;
extern bool g_logging;
extern bool g_disableRadio;

extern int isSafeContext();

//#define DEBUG_CONSOLE

//#define DISPLAY_IMGUI
#ifndef DISPLAY_IMGUI
#define DISABLE_IMGUI
#endif



//Uncomment this to enable logging make sure this is commited with this commented out!!!!!!
#define LOGGING


#ifdef LOGGING
#define LOG(s, ...) if ( g_log ) fprintf(g_log, s, __VA_ARGS__);
#else
#define LOG(s, ...) /*nothing*/
#endif

#define LOG_BREAK() LOG("===================\n")

#define DAMAGE_LOGGING
#ifdef DAMAGE_LOGGING
#define LOG_DAMAGE(s,...) LOG(s, __VA_ARGS__)
#else
#define LOG_DAMAGE(s,...)
#endif


#endif

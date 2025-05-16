// dllmain.cpp : Defines the entry point for the DLL application.
#include "stdafx.h"
#include <iostream>
#include <fcntl.h>
#include <stdio.h>
#include <io.h>
#include <windows.h>
#include <fstream>
#include <Common/Globals.h>

FILE* stream;
FILE* g_log = NULL;
int g_safeToRun = 0;
bool g_logging = false;
bool g_disableRadio = false;

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
					 )
{
	

	

	switch (ul_reason_for_call)
	{
	case DLL_PROCESS_ATTACH:
#ifdef DEBUG_CONSOLE
		if (AllocConsole())
		{
			freopen_s(&stream, "CONOUT$", "w", stdout);
			SetConsoleTitle((L"DCS A-4 Debug Console"));
			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE), FOREGROUND_BLUE | FOREGROUND_GREEN | FOREGROUND_BLUE);
		}
#endif
		size_t size;
		getenv_s( &size, NULL, 0, "A4E_EFM_RADIO_DISABLE" );

		if ( size )
			g_disableRadio = true;

#ifdef LOGGING_OLD
		size_t size;
		getenv_s( &size, NULL, 0, "A4E_EFM_LOGGING" );
		if ( size )
		{
			g_logging = true;
		}

		getenv_s( &size, NULL, 0, "ENV_DISABLE_COPY_PROTECTION" );
		if ( g_logging )
		{
			fopen_s( &g_log, "C:/tmp/log.txt", "w" );
		}
#endif
		break;
	case DLL_THREAD_ATTACH:
		break;
	case DLL_THREAD_DETACH:
	case DLL_PROCESS_DETACH:
#ifdef LOGGING_OLD
		if ( g_logging )
			fclose(g_log);
#endif
		break;
	}
	return TRUE;
}


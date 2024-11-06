//=========================================================================//
//
//		FILE NAME	: Safe.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: October 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Confirms that the program is running with the files as 
//						expected.
//
//================================ Includes ===============================//
#include "Hashes.h"
#include <wincrypt.h>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
#include <Common/Globals.h>
#include "Scooter.h"
//=========================================================================//

enum FileCodes
{
	NOT_FOUND = 0,
	UNSAFE = 0,
	SAFE = 1
};

#define BUFFER_SIZE 1024
#define HASH_LEN 20
#define STRING_BUF_LEN 200

static int getA4Root( WCHAR* buffer, DWORD length );
static int getHash(LPCWSTR filename, BYTE* buffer );
static int verifyHash( const BYTE* hash1, const BYTE* hash2 );
static void logHash( BYTE* hash );

int isSafeContext()
{
	int safe = SAFE;
	WCHAR folderRoot[STRING_BUF_LEN];
	if ( ! getA4Root( folderRoot, STRING_BUF_LEN ) )
	{
		return UNSAFE;
	}

	LOG( "Root A-4E-C Folder: %ws\n", folderRoot );

	int numberOfFiles = sizeof(files)/sizeof(WCHAR*);

	BYTE hash[HASH_LEN];
	WCHAR path[STRING_BUF_LEN];
	for ( int i = 0; i < numberOfFiles; i++ )
	{
		swprintf_s( path, STRING_BUF_LEN, L"%ws\\%ws ", folderRoot, files[i]);
		LOG ( "Path: %ws\n", path );
		if ( getHash( path, hash ) )
		{
			LOG ( "Checking %ws, Hash: ", files[i] );
			logHash( hash );
			LOG( "\n" );

			if ( verifyHash( hash, hashes[i] ) )
			{
				LOG( "Verified: %ws, Hash: ", files[i] );
				logHash( hash );
				LOG( "\n" );
			}
			else
			{
				LOG( "Mismatch.\n" );
				safe = UNSAFE;
			}
		}
		else
		{
			LOG ( "Couldn't get hash %ws\n", path );
			safe = UNSAFE;
		}
	}

	return safe;
}

int getA4Root( WCHAR* buffer, DWORD length )
{
	HMODULE hm = NULL;
	if ( ! GetModuleHandleEx(
		GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
		(LPCWSTR)ed_fm_simulate, &hm ) )
	{
		LOG( "GetModuleHandle failed: %d", GetLastError() );
		return 0;
	}

	WCHAR* path = (WCHAR*)malloc(sizeof(WCHAR)*length);

	if ( GetModuleFileName( hm, path, length ) == 0 )
	{
		LOG( "GetModuleFileName failed: %d", GetLastError() );
		free( path );
		return 0;
	}

	int i = 0;
	while ( path[i] )
	{
		i++;
	}

	int slashCount = 0;
	for ( ; i >= 0; i-- )
	{
		if ( path[i] == '\\' || path[i] == '/' )
		{
			slashCount++;
		}

		if ( slashCount >= 2 )
		{
			break;
		}
	}

	if ( slashCount )
	{
		swprintf_s( buffer, length, L"%.*s", i, path );
	}
	else
	{
		swprintf_s( buffer, length, L"" );
	}

	free( path );

	return 1;
}

int getHash( LPCWSTR filename, BYTE* hashBuffer )
{
	DWORD status = 0;
	HANDLE file = NULL;

	file = CreateFile( filename, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN, NULL );

	if ( file == INVALID_HANDLE_VALUE )
	{
		status = GetLastError();
		LOG( "Error opening file %ws\nError: %d\n", filename, status );
		return NOT_FOUND;
	}

	HCRYPTPROV provider = 0;
	HCRYPTHASH hash = 0;

	if ( ! CryptAcquireContext( &provider,
		NULL, 
		NULL, 
		PROV_RSA_FULL, 
		CRYPT_VERIFYCONTEXT ) )
	{
		status = GetLastError();
		LOG( "CryptAcquireContext failed: %d\n", status );
		CloseHandle( file );
		return UNSAFE;
	}

	if ( ! CryptCreateHash( provider, CALG_SHA1, 0, 0, &hash ) )
	{
		status = GetLastError();
		LOG( "CryptCreateHash failed: %d\n", status );
		CloseHandle( file );
		CryptReleaseContext( provider, 0 );
		return UNSAFE;
	}

	BOOL result = FALSE;

	
	DWORD bytesRead = 0;
	BYTE* buffer = (BYTE*)malloc( BUFFER_SIZE );

	while ( result = ReadFile( file, buffer, BUFFER_SIZE, &bytesRead, NULL ) )
	{
		if ( bytesRead == 0 )
			break;
		if ( ! CryptHashData( hash, buffer, bytesRead, 0 ) )
		{
			status = GetLastError();
			LOG( "CryptHashData failed: %d\n", status );
			CryptReleaseContext( provider, 0 );
			CryptDestroyHash( hash );
			CloseHandle( file );
			free( buffer );
			return UNSAFE;
		}
	}

	if ( ! result )
	{
		status = GetLastError();
		LOG( "ReadFile failed: %d\n", status );
		CryptReleaseContext( provider, 0 );
		CryptDestroyHash( hash );
		CloseHandle( file );
		free( buffer );
		return UNSAFE;
	}

	DWORD hashBytes = HASH_LEN;
	int safe = SAFE;

	if ( ! CryptGetHashParam( hash, HP_HASHVAL, hashBuffer, &hashBytes, 0 ) )
	{
		status = GetLastError();
		LOG( "CryptGetHashParam failed: %d\n", status );
		safe = UNSAFE;
	}

	CryptReleaseContext( provider, 0 );
	CryptDestroyHash( hash );
	CloseHandle( file );
	free( buffer );

	return safe;
}

int verifyHash( const BYTE* hash1, const BYTE* hash2 )
{
	for ( int i = 0; i < HASH_LEN; i++ )
	{
		if ( hash1[i] != hash2[i] )
		{
			return UNSAFE;
		}
	}

	return SAFE;
}

void logHash( BYTE* hash )
{
	for ( DWORD i = 0; i < HASH_LEN; i++ )
	{
		LOG( "%02x", hash[i] );
	}
}


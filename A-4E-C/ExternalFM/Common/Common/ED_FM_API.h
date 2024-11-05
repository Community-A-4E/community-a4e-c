// The following ifdef block is the standard way of creating macros which make exporting 
// from a DLL simpler. All files within this DLL are compiled with the ED_FM_TEMPLATE_EXPORTS
// symbol defined on the command line. This symbol should not be defined on any project
// that uses this DLL. This way any other project whose source files include this file see 
// ED_FM_TEMPLATE_API functions as being imported from a DLL, whereas this DLL sees symbols
// defined with this macro as being exported.

#pragma once
#ifndef ED_FM_API_H
#define ED_FM_API_H

#ifdef ED_FM_TEMPLATE_EXPORTS
#define ED_FM_API __declspec(dllexport)
#else
#define ED_FM_API __declspec(dllimport)
#endif

#endif
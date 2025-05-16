#pragma once
#define ED_COCKPIT_API_IMPORT __declspec(dllimport)


extern "C"
{
	ED_COCKPIT_API_IMPORT void ed_cockpit_dispatch_action_digital( int command );
	ED_COCKPIT_API_IMPORT void ed_cockpit_dispatch_action_analog( int command, float value );
	ED_COCKPIT_API_IMPORT void ed_cockpit_dispatch_action_to_device(unsigned char dev, int command, float value );
	
	ED_COCKPIT_API_IMPORT void* ed_cockpit_get_parameter_handle( const char* name );
	ED_COCKPIT_API_IMPORT void ed_cockpit_update_parameter_with_number( void* param, double number );
	ED_COCKPIT_API_IMPORT void ed_cockpit_update_parameter_with_string( void* param, const char* string );
	ED_COCKPIT_API_IMPORT bool ed_cockpit_parameter_value_to_number( void* param, double& number, bool interpolated );
	ED_COCKPIT_API_IMPORT bool ed_cockpit_parameter_value_to_string( void* param, char* buffer, unsigned int bufferSize );

	ED_COCKPIT_API_IMPORT void ed_cockpit_set_draw_argument( int arg, float value );
	ED_COCKPIT_API_IMPORT float ed_cockpit_get_draw_argument( int arg );
}
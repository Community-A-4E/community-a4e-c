//=========================================================================//
//
//		FILE NAME	: Scooter.cpp
//		AUTHOR		: Joshua Nelson
//		DATE		: March 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	Contains the exported function definitions called by 
//						Eagle Dynamics.
//
//================================ Includes ===============================//
#include "stdafx.h"
#include <Verify.h>
#include "Scooter.h"

#include <stdio.h>
#include <string>
#include <Common/Vec3.h>



#include "LuaVM.h"

#include <Common/Commands.h>
#include <Common/Globals.h>

#include "Damage.h"
#include "Scooter.h"
#include <LuaImGui.h>
#include <optional>

//============================= Statics ===================================//


static std::optional<Scooter::ParameterInterface> s_interface;
static std::optional<LuaVM> s_luaVM;
std::optional<Scooter::State> s_state;

//========================== Static Functions =============================//
static void init( const char* config );
static void cleanup();
static void checkCorruption(const char* str);
static void dumpMem( unsigned char* ptr, size_t size );
static void checkCompatibility( const char* path );
static bool searchFolder( const char* root, const char* folder, const char* file );

//========================== Static Constants =============================//
static constexpr bool s_NWSEnabled = false;


//=========================================================================//

void ImGuiLog( const char* c )
{
	LuaImGui::Log( log_buffer );
}

//Courtesy of SilentEagle
static inline int decodeClick( float& value )
{
	float deviceID;
	float normalised = modf( value, &deviceID );
	value = normalised * 8.0f - 2.0f;
	return (int)deviceID;
}

bool searchFolder( const char* root, const char* folder, const char* file )
{
	char path[200];
	sprintf_s( path, 200, "%s%s\\%s", root, folder, file );
	WIN32_FIND_DATAA data;
	HANDLE fileHandle = FindFirstFileA( path, &data );

	return fileHandle != INVALID_HANDLE_VALUE;
}

void checkCompatibility(const char* path)
{
	char aircraftFolder[200];
	strcpy_s( aircraftFolder, 200, path );

	char* ptr = aircraftFolder;
	while ( *ptr )
	{
		if ( *ptr == '/' )
			*ptr = '\\';
		ptr++;
	}

	char* lastSlash = strrchr( aircraftFolder, '\\' );

	//WHAT?
	if ( ! lastSlash )
		return;

	*(lastSlash + 1) = 0;

	char searchPath[200];
	sprintf_s( searchPath, 200, "%s*", aircraftFolder );

	WIN32_FIND_DATAA data;
	HANDLE handle = FindFirstFileA( searchPath, &data );
	if ( handle == INVALID_HANDLE_VALUE )
		return;

	bool found = false;

	do
	{
		if ( strcmp( data.cFileName, ".." ) == 0 || strcmp( data.cFileName, "." ) == 0 )
			continue;

		if ( data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY && 
			(searchFolder( aircraftFolder, data.cFileName, "CH_53.lua" ) || searchFolder( aircraftFolder, data.cFileName, "Ch47_Chinook.lua" ) ) )
		{
			found = true;
			break;
		}
	} while ( FindNextFileA( handle, &data ) );

	if ( ! found )
		return;
	
	int selection = MessageBoxA( 
		nullptr, 
		"The CH-53E and CH-47 mods are completely incompatible with the A-4E-C due to a DCS bug triggered\
 by the CH-53E and CH-47 configuration. This bug causes memory corruption and undefined behaviour.\
 To use the A-4E-C uninstall the CH-53E and CH-47 mods.", 
		"FATAL ERROR - CH-53E and/or CH-47 Mods Detected", MB_ABORTRETRYIGNORE | MB_ICONERROR );

	LOG( "ERROR: Incompatible mod found!\n" );

	if ( selection != IDIGNORE )
		std::terminate();
}

void init(const char* config)
{
	g_safeToRun = true;//Scooter::Verify(config);

	if ( g_safeToRun )
	{
		LuaImGui::Create( ImGui::SetCurrentContext, ImGui::SetAllocatorFunctions, ImPlot::SetCurrentContext );
		LuaImGui::AddItem( "Menu Name", "C++ Test", []()
			{
				ImGui::Text( "Hello World" );
		} );


		LuaImGui::Log("[Scooter]: Hash Verified");
	}

	srand( 741 );
	s_luaVM.emplace();

	char configFile[200];
	sprintf_s( configFile, 200, "%s/Config/config.lua", config );
	s_luaVM->dofile( configFile );
	std::vector<LERX> splines;
	s_luaVM->getSplines( "splines", splines );

	double wingTankOffset = 0.0;
	double fuseTankOffset = 0.0;
	double extTankOffset = 0.0;

	s_luaVM->getGlobalNumber( "external_tank_offset", extTankOffset);
	s_luaVM->getGlobalNumber( "fuselage_tank_offset", fuseTankOffset );
	s_luaVM->getGlobalNumber( "wing_tank_offset", wingTankOffset );

	//printf( "EXT: %lf, WNG: %lf, FUS: %lf\n", s_extTankOffset, s_wingTankOffset, s_fuseTankOffset );

	s_interface.emplace();
	Scooter::DamageProcessor::Create( *s_interface );


	s_state.emplace(splines,wingTankOffset,fuseTankOffset,extTankOffset, *s_interface);

	s_state->window = GetActiveWindow();
	printf( "Have window: %p\n", s_state->window );
	
	double ejectionVelocity = 0.0;
	s_luaVM->getGlobalNumber( "ejection_velocity", ejectionVelocity );
	s_state->avionics.getComputer().setEjectionVelocity( ejectionVelocity );
	printf( "Ejection Velocity: %lf\n", ejectionVelocity );

	LuaImGui::AddItem( "Menu Name", "C++ Test", [state = &s_state.value()]() {
		ImGui::Text("Mass: %lf", state->airframe.getMass());
	});

	
}

void cleanup()
{
	LuaImGui::Destroy();
	s_state.reset();
	s_interface.reset();
	Scooter::DamageProcessor::Destroy();

	s_luaVM.reset();

	releaseAllEmulatedKeys();
}

void checkCorruption(const char* str)
{
	//printf( "Validating Test buffer...\n" );

	/*if ( ! s_state->fuelSystem.m_enginePump )
		printf( "Memory corrupted! %s\n", str );
	else
		printf( "Memory Fine %str\n", str );*/
}


void ed_fm_add_local_force(double & x,double &y,double &z,double & pos_x,double & pos_y,double & pos_z)
{
	x = s_state->fm.getForce().x;
	y = s_state->fm.getForce().y;
	z = s_state->fm.getForce().z;

	pos_x = s_state->state.getCOM().x;
	pos_y = s_state->state.getCOM().y;
	pos_z = s_state->state.getCOM().z;
}

void ed_fm_add_global_force(double & x,double &y,double &z,double & pos_x,double & pos_y,double & pos_z)
{
	/*y = s_mass * 9.81;
	Vec3 pos = s_pos - s_fm.getCOM();
	pos_x = pos.x;
	pos_y = pos.y;
	pos_z = pos.z;*/
}

void ed_fm_add_global_moment(double & x,double &y,double &z)
{

}

void ed_fm_add_local_moment(double & x,double &y,double &z)
{
	x = s_state->fm.getMoment().x;
	y = s_state->fm.getMoment().y;
	z = s_state->fm.getMoment().z + s_state->airframe.getCatMoment();
}

void ed_fm_simulate(double dt)
{
	if ( ! g_safeToRun )
		return;

	Logger::time( dt );

	//Pre update
	if ( s_state->parameter_interface.getAvionicsAlive() )
	{

		//s_sidewinder->init();
		//s_sidewinder->update();
		//s_ils->test();
		//s_ils->update();
		s_state->state.setRadarAltitude( s_state->parameter_interface.getRadarAltitude() );
		s_state->avionics.setYawDamperPower( s_state->parameter_interface.getYawDamper() > 0.5 );
		s_state->fm.setCockpitShakeModifier( s_state->parameter_interface.getCockpitShake() );
		s_state->airframe.setFlapsPosition( s_state->parameter_interface.getFlaps() );
		s_state->airframe.setSpoilerPosition( s_state->parameter_interface.getSpoilers() );
		s_state->airframe.setAirbrakePosition( s_state->parameter_interface.getSpeedBrakes() );
		s_state->airframe.setGearLPosition( s_state->parameter_interface.getGearLeft() );
		s_state->airframe.setGearRPosition( s_state->parameter_interface.getGearRight() );
		s_state->airframe.setGearNPosition( s_state->parameter_interface.getGearNose() );

		s_state->fuelSystem.setFuelCapacity( 
			s_state->parameter_interface.getLTankCapacity(),
			s_state->parameter_interface.getCTankCapacity(),
			s_state->parameter_interface.getRTankCapacity() 
		);

		s_state->avionics.getComputer().setGunsightAngle( s_state->parameter_interface.getGunsightAngle() );
		s_state->avionics.getComputer().setTarget( s_state->parameter_interface.getSetTarget(), s_state->parameter_interface.getRadarDisabled() ? s_state->parameter_interface.getSlantRange() : s_state->radar.getRange() );
		s_state->avionics.getComputer().setPower( s_state->parameter_interface.getCP741Power() );

		s_state->input.pitchTrim() = s_state->parameter_interface.getPitchTrim();
		s_state->input.rollTrim() = s_state->parameter_interface.getRollTrim();
		s_state->input.yawTrim() = s_state->parameter_interface.getRudderTrim();


		//printf( "x: %lf, y: %lf, z: %lf, mass: %lf\n", s_state->state.getCOM().x, s_state->state.getCOM().y, s_state->state.getCOM().z, s_state->airframe.getMass() );
		s_state->engine.setThrottle( s_state->parameter_interface.getEngineThrottlePosition() );
		s_state->engine.setBleedAir( s_state->parameter_interface.getBleedAir() > 0.1 );
		s_state->engine.setIgnitors( s_state->parameter_interface.getIgnition() > 0.1 );

		s_state->state.setGForce( s_state->parameter_interface.getGForce() );

		s_state->fuelSystem.setBoostPumpPower( s_state->parameter_interface.getElecMonitoredAC() );
		s_state->radar.setDisable( s_state->parameter_interface.getRadarDisabled() );
	}

	HWND focus = GetFocus();
	bool oldFocus = s_state->focus;
	s_state->focus = focus == s_state->window;
	if ( oldFocus && ! s_state->focus )
		releaseAllEmulatedKeys();

	if ( s_state->focus )
	{
		s_state->mouseControl.update( s_state->input.mouseXAxis().getValue(), s_state->input.mouseYAxis().getValue() );
	}

	//Update
	s_state->input.update(s_state->parameter_interface.getWheelBrakeAssist());
	s_state->engine.updateEngine(dt);
	s_state->airframe.airframeUpdate(dt);
	s_state->fuelSystem.update( dt );
	s_state->avionics.updateAvionics(dt);
	s_state->fm.calculateAero(dt);
	s_state->radar.update( dt );

	if ( s_state->parameter_interface.egg() )
	{
		egg( dt, &s_state->asteroids, s_state->input );
	}


	//yaw += dyaw;
	//pitch += dpitch;
	//
	////update_command( s_missile, s_state->state.getWorldPosition(), s_state->avionics.getComputer().m_target );
	//Vec3 pos;
	////printf( "%lf,%lf,%lf -> %lf, %lf, %lf\n", dir.x, dir.y, dir.z, new_dir.x, new_dir.y, new_dir.z);

	//double new_yaw = 0.0;
	//double new_pitch = 0.0;
	//Vec3 dir = get_vecs( s_missile, new_pitch, new_yaw, pos );

	//static int counter = 0;
	//counter = ( counter + 1 ) % 300;
	//if ( ! s_steering && counter == 0 )
	//{
	//	yaw = new_yaw;
	//	pitch = new_pitch;
	//}
	//	
	//printf( "%d Steering\n", s_steering );

	//Vec3 new_dir = Scooter::directionVector( pitch, yaw );
	//Vec3 newPos = new_dir * 1000.0 + pos;
	//printf( "Spot pos: %lf,%lf,%lf Missile Pos: %lf,%lf,%lf\n", newPos.x, newPos.y, newPos.z, pos.x,pos.y,pos.z );
	//set_laser_spot_pos( s_spot, newPos );

	//s_scope->setBlob( 1, 0.5, 0.5, 1.0 );
	
	//Post update
	s_state->parameter_interface.setRPM(s_state->engine.getRPMNorm()*100.0);
	s_state->parameter_interface.setFuelFlow( s_state->engine.getFuelFlow() );

	s_state->parameter_interface.setThrottlePosition(s_state->input.throttleNorm());
	s_state->parameter_interface.setStickPitch(s_state->airframe.getElevator());

	s_state->parameter_interface.setStickRoll( s_state->input.roll() + s_state->input.rollTrim() );
	s_state->parameter_interface.setRudderPedals(s_state->input.yawAxis().getValue());
	s_state->parameter_interface.setLeftBrakePedal( s_state->input.brakeLeft() );
	s_state->parameter_interface.setRightBrakePedal( s_state->input.brakeRight() );

	s_state->parameter_interface.setStickInputPitch( s_state->input.pitch() );
	s_state->parameter_interface.setStickInputRoll( s_state->input.roll() );

	s_state->parameter_interface.setInternalFuel( s_state->fuelSystem.getFuelQtyInternal() );
	s_state->parameter_interface.setExternalFuel( s_state->fuelSystem.getFuelQtyExternal() );
	s_state->parameter_interface.setAOA( s_state->state.getAOA() );
	s_state->parameter_interface.setBeta( s_state->state.getBeta() );
	s_state->parameter_interface.setAOAUnits( rawAOAToUnits(s_state->state.getAOA()) );
	s_state->parameter_interface.setValidSolution( s_state->avionics.getComputer().getSolution() );
	s_state->parameter_interface.setTargetSet( s_state->avionics.getComputer().getTargetSet() );
	s_state->parameter_interface.setInRange( s_state->avionics.getComputer().inRange() );

	s_state->parameter_interface.setLeftSlat( s_state->airframe.getSlatLPosition() );
	s_state->parameter_interface.setRightSlat( s_state->airframe.getSlatRPosition() );

	s_state->parameter_interface.setUsingFFB( s_state->input.getFFBEnabled() );
	s_state->parameter_interface.SetLSkid( s_state->airframe.IsSkiddingLeft() );
	s_state->parameter_interface.SetRSkid( s_state->airframe.IsSkiddingRight() );

	//s_state->interface.setEngineStall( s_state->engine.stalled() ); Disabled for beta-5 re-enable when ready.

	//Starting to try to move some of these tests into the cpp. Make it less spaghetti.
	//Ultimately we should move this into the avionics class.
	s_state->parameter_interface.setFuelTransferCaution( s_state->parameter_interface.getElecPrimaryAC() && (s_state->parameter_interface.getMasterTest() || s_state->fuelSystem.getFuelTransferCaution()) );
	s_state->parameter_interface.setFuelBoostCaution( s_state->parameter_interface.getElecPrimaryAC() && (s_state->parameter_interface.getMasterTest() || s_state->fuelSystem.getFuelBoostCaution()) );

	Logger::end();
}

void ed_fm_set_atmosphere(
							double h,//altitude above sea level
							double t,//current atmosphere temperature , Kelwins
							double a,//speed of sound
							double ro,// atmosphere density
							double p,// atmosphere pressure
							double wind_vx,//components of velocity vector, including turbulence in world coordinate system
							double wind_vy,//components of velocity vector, including turbulence in world coordinate system
							double wind_vz //components of velocity vector, including turbulence in world coordinate system
						)
{

	s_state->state.setCurrentAtmosphere( t, a, ro, p, Vec3( wind_vx, wind_vy, wind_vz ) );
}
/*
called before simulation to set up your environment for the next step
*/
void ed_fm_set_current_mass_state 
(
	double mass,
	double center_of_mass_x,
	double center_of_mass_y,
	double center_of_mass_z,
	double moment_of_inertia_x,
	double moment_of_inertia_y,
	double moment_of_inertia_z
)
{
	
	s_state->airframe.setMass(mass);
	Vec3 com = Vec3( center_of_mass_x, center_of_mass_y, center_of_mass_z );
	//printf( "M: %lf | COM: %lf,%lf,%lf | MOI: %lf,%lf,%lf\n", mass, com.x,com.y,com.z, moment_of_inertia_x, moment_of_inertia_y, moment_of_inertia_z );
	s_state->state.setCOM( com );
	s_state->fm.setCOM(com);
}
/*
called before simulation to set up your environment for the next step
*/
void ed_fm_set_current_state
(
	double ax,//linear acceleration component in world coordinate system
	double ay,//linear acceleration component in world coordinate system
	double az,//linear acceleration component in world coordinate system
	double vx,//linear velocity component in world coordinate system
	double vy,//linear velocity component in world coordinate system
	double vz,//linear velocity component in world coordinate system
	double px,//center of the body position in world coordinate system
	double py,//center of the body position in world coordinate system
	double pz,//center of the body position in world coordinate system
	double omegadotx,//angular accelearation components in world coordinate system
	double omegadoty,//angular accelearation components in world coordinate system
	double omegadotz,//angular accelearation components in world coordinate system
	double omegax,//angular velocity components in world coordinate system
	double omegay,//angular velocity components in world coordinate system
	double omegaz,//angular velocity components in world coordinate system
	double quaternion_x,//orientation quaternion components in world coordinate system
	double quaternion_y,//orientation quaternion components in world coordinate system
	double quaternion_z,//orientation quaternion components in world coordinate system
	double quaternion_w //orientation quaternion components in world coordinate system
)
{
	Vec3 direction;

	double x = quaternion_x;
	double y = quaternion_y;
	double z = quaternion_z;
	double w = quaternion_w;

	double y2 = y + y;
	double z2 = z + z;

	double yy = y * y2;
	double zz = z * z2;

	double xy = x * y2;
	double xz = x * z2;

	double wz = w * z2;
	double wy = w * y2;


	direction.x = 1.0 - (yy + zz);
	direction.y = xy + wz;
	direction.z = xz - wy;

	Vec3 up;
	up.x = 2.0 * (x*y - w*z);
	up.y = 1.0 - 2.0 * (x*x + z*z);
	up.z = 2.0 * (y*z + w*x);
	

	s_state->parameter_interface.setWorldAcceleration( Vec3( ax, ay, az ) );

	Vec3 globalUp;
	double x2 = x + x;
	double yz = y * z2;
	double wx = w * x2;

	double xx = x * x2;

	globalUp.x = xy + wz;
	globalUp.y = 1.0 - (xx + zz);
	globalUp.z = yz - wx;

	s_state->state.SetWorldQuaternion( -quaternion_w, -quaternion_x, quaternion_z, quaternion_y );
	s_state->state.setCurrentStateWorldAxis( Vec3( px, py, pz ), Vec3( vx, vy, vz ), direction, up, -globalUp );


	Force f;
	f.force = globalUp * s_state->airframe.getMass() * 9.81;
	f.pos = s_state->state.getCOM();

	//s_state->fm.getForces().push_back( f );
}


void ed_fm_set_current_state_body_axis
(
	double ax,//linear acceleration component in body coordinate system
	double ay,//linear acceleration component in body coordinate system
	double az,//linear acceleration component in body coordinate system
	double vx,//linear velocity component in body coordinate system
	double vy,//linear velocity component in body coordinate system
	double vz,//linear velocity component in body coordinate system
	double wind_vx,//wind linear velocity component in body coordinate system
	double wind_vy,//wind linear velocity component in body coordinate system
	double wind_vz,//wind linear velocity component in body coordinate system

	double omegadotx,//angular accelearation components in body coordinate system
	double omegadoty,//angular accelearation components in body coordinate system
	double omegadotz,//angular accelearation components in body coordinate system
	double omegax,//angular velocity components in body coordinate system
	double omegay,//angular velocity components in body coordinate system
	double omegaz,//angular velocity components in body coordinate system
	double yaw,  //radians
	double pitch,//radians
	double roll, //radians
	double common_angle_of_attack, //AoA radians
	double common_angle_of_slide   //AoS radians
)
{
	s_state->state.setCurrentStateBodyAxis(common_angle_of_attack, common_angle_of_slide, Vec3(roll, yaw, pitch), Vec3(omegax, omegay, omegaz), Vec3(omegadotx, omegadoty, omegadoty), Vec3(vx, vy, vz), Vec3(vx - wind_vx, vy - wind_vy, vz - wind_vz), Vec3(ax, ay, az));
}

void ed_fm_on_damage( int element, double element_integrity_factor )
{
	//printf( "On Damage: %d -> %lf\n", element, element_integrity_factor );

	Scooter::DamageProcessor::GetDamageProcessor().OnDamage( element, element_integrity_factor );
	s_state->airframe.setIntegrityElement((Scooter::Airframe::Damage)element, (float)element_integrity_factor);
}

void ed_fm_set_surface
( 
	double		h,//surface height under the center of aircraft
	double		h_obj,//surface height with objects
	unsigned	surface_type,
	double		normal_x,//components of normal vector to surface
	double		normal_y,//components of normal vector to surface
	double		normal_z//components of normal vector to surface
)
{
	bool skiddable_surface = false;

	switch ( surface_type )
	{
	case Scooter::Radar::TerrainType::AIRFIELD:
	case Scooter::Radar::TerrainType::ROAD:
	case Scooter::Radar::TerrainType::RAILWAY:
	case Scooter::Radar::TerrainType::SEA: // for carrier
	case Scooter::Radar::TerrainType::LAKE:
		skiddable_surface = true;
		break;
	}
	s_state->airframe.SetSkiddableSurface( skiddable_surface );
	//printf( "Type: %d\n", surface_type );
	s_state->state.setSurface( s_state->state.getWorldPosition().y - h_obj, Vec3( normal_x, normal_y, normal_z ) );
}

/*
input handling
*/
void ed_fm_set_command
(
	int command,
	float value
)
{

	switch (command)
	{
	case Scooter::Control::PITCH:
		s_state->input.pitch( value );
		break;
	case Scooter::Control::ROLL:
		s_state->input.roll( value );
		break;
	case Scooter::Control::YAW:
		s_state->input.yaw( value );
		break;
	case Scooter::Control::THROTTLE:
		s_state->input.throttle( value );
		break;
	case DEVICE_COMMANDS_WHEELBRAKE_AXIS:
		s_state->input.brakeLeft( value );
		s_state->input.brakeRight( value );
		break;
	case DEVICE_COMMANDS_LEFT_WHEELBRAKE_AXIS:
		s_state->input.brakeLeft( value );
		break;
	case DEVICE_COMMANDS_RIGHT_WHEELBRAKE_AXIS:
		s_state->input.brakeRight( value );
		break;
	case DEVICE_COMMANDS_COMBINED_WHEEL_BRAKE_AXIS:
		s_state->input.brakeRightDirect( std::max( value, 0.0f ) );
		s_state->input.brakeLeftDirect( std::max( -value, 0.0f ) );
		break;
	case Scooter::Control::RUDDER_LEFT_START:
		s_state->input.yawAxis().keyDecrease();
		break;
	case Scooter::Control::RUDDER_LEFT_STOP:
		s_state->input.yawAxis().reset();
		break;
	case Scooter::Control::RUDDER_RIGHT_START:
		s_state->input.yawAxis().keyIncrease();
		break;
	case Scooter::Control::RUDDER_RIGHT_STOP:
		s_state->input.yawAxis().reset();
		break;
	case Scooter::Control::ROLL_LEFT_START:
		s_state->input.rollAxis().keyDecrease();
		break;
	case Scooter::Control::ROLL_LEFT_STOP:
		s_state->input.rollAxis().reset();
		break;
	case Scooter::Control::ROLL_RIGHT_START:
		s_state->input.rollAxis().keyIncrease();
		break;
	case Scooter::Control::ROLL_RIGHT_STOP:
		s_state->input.rollAxis().reset();
		break;
	case Scooter::Control::PITCH_DOWN_START:
		s_state->input.pitchAxis().keyDecrease();
		break;
	case Scooter::Control::PITCH_DOWN_STOP:
		s_state->input.pitchAxis().stop();
		break;
	case Scooter::Control::PITCH_UP_START:
		s_state->input.pitchAxis().keyIncrease();
		break;
	case Scooter::Control::PITCH_UP_STOP:
		s_state->input.pitchAxis().stop();
		break;
	case Scooter::Control::THROTTLE_DOWN_START:
		//Throttle is inverted for some reason in DCS
		s_state->input.throttleAxis().keyIncrease();
		break;
	case Scooter::Control::THROTTLE_STOP:
		s_state->input.throttleAxis().stop();
		break;
	case Scooter::Control::THROTTLE_UP_START:
		s_state->input.throttleAxis().keyDecrease();
		break;
	case KEYS_BRAKESON:
		s_state->input.leftBrakeAxis().keyIncrease();
		s_state->input.rightBrakeAxis().keyIncrease();
		break;
	case KEYS_BRAKESOFF:
		s_state->input.leftBrakeAxis().slowReset();
		s_state->input.rightBrakeAxis().slowReset();
		break;

	case KEYS_BRAKESONLEFT:
		s_state->input.leftBrakeAxis().keyIncrease();
		break;
	case KEYS_BRAKESOFFLEFT:
		s_state->input.leftBrakeAxis().slowReset();
		break;
	case KEYS_BRAKESONRIGHT:
		s_state->input.rightBrakeAxis().keyIncrease();
		break;
	case KEYS_BRAKESOFFRIGHT:
		s_state->input.rightBrakeAxis().slowReset();
		break;
	case KEYS_TOGGLESLATSLOCK:
		//Weight on wheels plus lower than 50 kts.
		if ( s_state->airframe.getNoseCompression() > 0.01 && magnitude(s_state->state.getLocalSpeed()) < 25.0 )
			s_state->airframe.toggleSlatsLocked();

		//s_state->airframe.setDamageDelta( Scooter::Airframe::Damage::WING_L_IN, 0.25 );
		//s_state->airframe.breakWing();

		//ed_fm_on_damage( (int)Scooter::Airframe::Damage::FUSELAGE_BOTTOM, 0.5 );
		//ed_fm_on_damage( (int)Scooter::Airframe::Damage::NOSE_CENTER, 0.8 );
		//ed_fm_on_damage( (int)Scooter::Airframe::Damage::NOSE_LEFT_SIDE, 0.8 );
		//ed_fm_on_damage( (int)Scooter::Airframe::Damage::FUSELAGE_BOTTOM, 0.4 );
		
		break;
	case KEYS_PLANEFIREON:
		s_state->asteroids.fire( true );
		break;
	case KEYS_PLANEFIREOFF:
		s_state->asteroids.fire( false );
		break;
	case DEVICE_COMMANDS_MOUSE_X:
		s_state->input.mouseXAxis().updateAxis( value );
		break;
	case DEVICE_COMMANDS_MOUSE_Y:
		s_state->input.mouseYAxis().updateAxis( value );
		break;
	case KEYS_MODIFIER_LEFT_DOWN:
		keyCONTROL( true );
		leftMouse( true );
		break;
	case KEYS_MODIFIER_LEFT_UP:
		keyCONTROL( false );
		leftMouse( false );
		break;
	case KEYS_MODIFIER_RIGHT_DOWN:
		keySHIFT( true );
		rightMouse( true );
		break;
	case KEYS_MODIFIER_RIGHT_UP:
		keySHIFT( false );
		rightMouse( false );
		break;
	default:
		;// printf( "number %d: %lf\n", command, value );
	}

	if ( command >= 3000 && command < 4000 )
	{
		int deviceId = decodeClick( value );

		//Do this when we have more than one device to check.
		/*switch ( deviceId )
		{

		}*/
	}

	if ( s_state->radar.handleInput( command, value ) )
		return;

	if ( s_state->fuelSystem.handleInput( command, value ) )
		return;

	if ( s_state->avionics.handleInput( command, value ) )
		return;

	if ( s_state->engine.handleInput( command, value ) )
		return;
}

/*
	Mass handling 

	will be called  after ed_fm_simulate :
	you should collect mass changes in ed_fm_simulate 

	double delta_mass = 0;
	double x = 0;
	double y = 0; 
	double z = 0;
	double piece_of_mass_MOI_x = 0;
	double piece_of_mass_MOI_y = 0; 
	double piece_of_mass_MOI_z = 0;
 
	//
	while (ed_fm_change_mass(delta_mass,x,y,z,piece_of_mass_MOI_x,piece_of_mass_MOI_y,piece_of_mass_MOI_z))
	{
	//internal DCS calculations for changing mass, center of gravity,  and moments of inertia
	}
*/

bool ed_fm_change_mass  (double & delta_mass,
						double & delta_mass_pos_x,
						double & delta_mass_pos_y,
						double & delta_mass_pos_z,
						double & delta_mass_moment_of_inertia_x,
						double & delta_mass_moment_of_inertia_y,
						double & delta_mass_moment_of_inertia_z
						)
{
	Scooter::FuelSystem2::Tank tank = s_state->fuelSystem.getSelectedTank();
	if ( tank == Scooter::FuelSystem2::NUMBER_OF_TANKS )
	{
		s_state->fuelSystem.setSelectedTank( Scooter::FuelSystem2::TANK_FUSELAGE );
		return false;
	}

	const Vec3& pos = s_state->fuelSystem.getFuelPos(tank);
	//Vec3 r = pos - s_state->state.getCOM();
	
	delta_mass = s_state->fuelSystem.getFuelQtyDelta(tank);
	s_state->fuelSystem.setFuelPrevious( tank );

	//printf( "Tank %d, Pos: %lf, %lf, %lf, dm=%lf\n", tank, pos.x, pos.y, pos.z, delta_mass );

	delta_mass_pos_x = pos.x;
	delta_mass_pos_y = pos.y;
	delta_mass_pos_z = pos.z;

	s_state->fuelSystem.setSelectedTank((Scooter::FuelSystem2::Tank)((int)tank + 1));
	return true;
}
/*
	set internal fuel volume , init function, called on object creation and for refueling , 
	you should distribute it inside at different fuel tanks
*/
void ed_fm_set_internal_fuel(double fuel)
{
	//printf( "Set internal fuel: %lf\n", fuel );
	s_state->fuelSystem.setInternal( fuel );
}

void ed_fm_refueling_add_fuel( double fuel )
{
	bool airborne = ! (s_state->airframe.getNoseCompression() > 0.0) ;
	s_state->fuelSystem.addFuel( fuel, airborne );
}

/*
	get internal fuel volume 
*/
double ed_fm_get_internal_fuel()
{
	return s_state->fuelSystem.getFuelQtyInternal();
}

/*
	set external fuel volume for each payload station , called for weapon init and on reload
*/
void  ed_fm_set_external_fuel (int	 station,
								double fuel,
								double x,
								double y,
								double z)
{
	constexpr double tankOffset = 0.89;

	//printf( "Station: %d, Fuel: %lf, Z: %lf, COM %lf\n", station, fuel, z, s_state->state.getCOM().z );
	s_state->fuelSystem.setFuelQty( (Scooter::FuelSystem2::Tank)(station + 1), Vec3( x - tankOffset, y, z ), fuel );//0.25
}
/*
	get external fuel volume 
*/
double ed_fm_get_external_fuel ()
{
	return s_state->fuelSystem.getFuelQtyExternal();
}

void ed_fm_set_draw_args (EdDrawArgument * drawargs,size_t size)
{

	if (size > 616)
	{	
		drawargs[611].f = drawargs[0].f;
		drawargs[614].f = drawargs[3].f;
		drawargs[616].f = drawargs[5].f;
	}

	drawargs[LEFT_AILERON].f = float(s_state->airframe.getAileronLeft());
	drawargs[RIGHT_AILERON].f = float(s_state->airframe.getAileronRight());

	drawargs[LEFT_ELEVATOR].f = float(s_state->airframe.getElevator());
	drawargs[RIGHT_ELEVATOR].f = float(s_state->airframe.getElevator());

	drawargs[RUDDER].f = -float(s_state->airframe.getRudder());

	drawargs[LEFT_FLAP].f = float(s_state->airframe.getFlapsPosition());
	drawargs[RIGHT_FLAP].f = float(s_state->airframe.getFlapsPosition());

	drawargs[LEFT_SLAT].f = float(s_state->airframe.getSlatLPosition());
	drawargs[RIGHT_SLAT].f = float(s_state->airframe.getSlatRPosition());

	drawargs[AIRBRAKE].f = float(s_state->airframe.getSpeedBrakePosition());

	//drawargs[HOOK].f = 1.0;//s_state->airframe.getHookPosition();

	drawargs[STABILIZER_TRIM].f = float( s_state->airframe.getStabilizerAnim() );

	//Fan 325 RPM
	//drawargs[325].f = 1.0;

	//This is the launch bar argument.
	drawargs[85].f = 1.0;

	//This is the refueling probe argument.
	drawargs[22].f = 1.0;

	s_state->airframe.SetLeftWheelArg( drawargs[103].f );
	s_state->airframe.SetRightWheelArg( drawargs[102].f );



}

double ed_fm_get_param(unsigned index)
{

	switch (index)
	{
	case ED_FM_SUSPENSION_0_GEAR_POST_STATE:
	case ED_FM_SUSPENSION_0_DOWN_LOCK:
	case ED_FM_SUSPENSION_0_UP_LOCK:
		return s_state->airframe.getGearNPosition();
	case ED_FM_SUSPENSION_1_GEAR_POST_STATE:
	case ED_FM_SUSPENSION_1_DOWN_LOCK:
	case ED_FM_SUSPENSION_1_UP_LOCK:
		return s_state->airframe.getGearLPosition();
	case ED_FM_SUSPENSION_2_GEAR_POST_STATE:
	case ED_FM_SUSPENSION_2_DOWN_LOCK:
	case ED_FM_SUSPENSION_2_UP_LOCK:
		return s_state->airframe.getGearRPosition();

	case ED_FM_ANTI_SKID_ENABLE:
		break;
	case ED_FM_CAN_ACCEPT_FUEL_FROM_TANKER:
		return 1000.0;

	case ED_FM_ENGINE_1_CORE_RPM:
	case ED_FM_ENGINE_1_RPM:
		return s_state->engine.getRPM();

	case ED_FM_ENGINE_1_TEMPERATURE:
		return 23.0;

	case ED_FM_ENGINE_1_OIL_PRESSURE:
		return 600.0;

	case ED_FM_OXYGEN_SUPPLY:
		return s_state->avionics.getOxygen() ? 101000.0 : 0.0;

	case ED_FM_FLOW_VELOCITY:
		return s_state->avionics.getOxygen() ? 1.0 : 0.0;

	case ED_FM_ENGINE_1_FUEL_FLOW:
		return s_state->engine.getFuelFlow();

	case ED_FM_ENGINE_1_RELATED_THRUST:
	case ED_FM_ENGINE_1_CORE_RELATED_THRUST:
		return s_state->engine.getThrust() / c_maxStaticThrust;
	case ED_FM_ENGINE_1_RELATED_RPM:
		return s_state->engine.getRPMNorm();
	case ED_FM_ENGINE_1_CORE_RELATED_RPM:
		//return 0.0;
		return s_state->engine.getRPMNorm();

	case ED_FM_ENGINE_1_CORE_THRUST:
	case ED_FM_ENGINE_1_THRUST:
		return s_state->engine.getThrust();
	case ED_FM_ENGINE_1_COMBUSTION:
		return s_state->engine.getFuelFlow() / c_fuelFlowMax;
	case ED_FM_SUSPENSION_1_RELATIVE_BRAKE_MOMENT:
		return s_state->parameter_interface.getChocks() ? 1.0 : pow(s_state->input.brakeLeft(), 3.0);
	case ED_FM_SUSPENSION_2_RELATIVE_BRAKE_MOMENT:
		return s_state->parameter_interface.getChocks() ? 1.0 : pow(s_state->input.brakeRight(), 3.0);
	case ED_FM_SUSPENSION_0_WHEEL_SELF_ATTITUDE:
		return ! s_state->airframe.GetNoseWheelFix();
	case ED_FM_SUSPENSION_0_WHEEL_YAW:
		return s_state->airframe.GetNoseWheelFix() ? s_state->airframe.GetNoseWheelAngle() : 0.0;
	case ED_FM_STICK_FORCE_CENTRAL_PITCH:  // i.e. trimmered position where force feeled by pilot is zero
		s_state->input.setFFBEnabled(true);
		return s_state->airframe.getElevatorZeroForceDeflection();
	case ED_FM_STICK_FORCE_FACTOR_PITCH:
		return s_state->input.getFFBPitchFactor();
	//case ED_FM_STICK_FORCE_SHAKE_AMPLITUDE_PITCH:
	//case ED_FM_STICK_FORCE_SHAKE_FREQUENCY_PITCH:

	case ED_FM_STICK_FORCE_CENTRAL_ROLL:   // i.e. trimmered position where force feeled by pilot is zero
		return s_state->input.rollTrim();
	case ED_FM_STICK_FORCE_FACTOR_ROLL:
		return s_state->input.getFFBRollFactor();
	//case ED_FM_STICK_FORCE_SHAKE_AMPLITUDE_ROLL:
	//case ED_FM_STICK_FORCE_SHAKE_FREQUENCY_ROLL:
	}

	return 0;

}

bool ed_fm_pop_simulation_event(ed_fm_simulation_event& out)
{
	static int counter = 0;

	if (s_state->airframe.catapultState() == Scooter::Airframe::ON_CAT_NOT_READY && !s_state->airframe.catapultStateSent())
	{
		out.event_type = ED_FM_EVENT_CARRIER_CATAPULT;
		out.event_params[0] = 0;
		s_state->airframe.catapultStateSent() = true;
		return true;
	}
	else if (s_state->airframe.catapultState() == Scooter::Airframe::ON_CAT_READY )
	{
		s_state->airframe.catapultStateSent() = true;
		bool autoMode = s_state->parameter_interface.getCatAutoMode();
		double thrust = 0.0;
		double speed = 0.0;
		if ( ! autoMode )
		{
			speed = 60.0f + 20.0 * std::min( s_state->airframe.getMass() / c_maxTakeoffMass, 1.0 );
			thrust = s_state->engine.getThrust();
		}

		out.event_type = ED_FM_EVENT_CARRIER_CATAPULT;
		out.event_params[0] = 1;
		out.event_params[1] = 3.0f;
		out.event_params[2] = float(speed);
		out.event_params[3] = float(thrust);
		s_state->airframe.catapultState() = Scooter::Airframe::ON_CAT_WAITING;
		return true;
	}
	else
	{
		Scooter::Airframe::Damage damage;
		float integrity;
		if ( s_state->airframe.processDamageStack( damage, integrity ) )
		{
			out.event_type = ED_FM_EVENT_STRUCTURE_DAMAGE;
			out.event_params[0] = (float)damage;
			out.event_params[1] = integrity;
			printf( "Damage Stack {%f|%f}\n", (float)damage, integrity );
			return true;
		}
	}

	/*if ( counter == 0 )
	{
		strcpy_s( out.event_message, 512, "JET_ENGINE_STARTUP_BLAST" );
		out.event_type = ED_FM_EVENT_EFFECT;
		out.event_params[0] = -1;
		out.event_params[1] = 1.0f;
		counter++;
		printf( "Leak\n" );
		return true;
	}*/

	counter = 0;
	return false;
}

bool ed_fm_push_simulation_event(const ed_fm_simulation_event& in)
{
	if (in.event_type == ED_FM_EVENT_CARRIER_CATAPULT)
	{
		if (in.event_params[0] == 1)
		{
			s_state->airframe.catapultState() = Scooter::Airframe::ON_CAT_NOT_READY;
		}
		else if (in.event_params[0] == 2)
		{
			s_state->airframe.catapultState() = Scooter::Airframe::ON_CAT_LAUNCHING;
		}
		else if (in.event_params[0] == 3)
		{
			if (s_state->airframe.catapultState() == Scooter::Airframe::ON_CAT_LAUNCHING)
			{
				s_state->airframe.catapultState() = Scooter::Airframe::OFF_CAT;
			}
			else
			{
				s_state->airframe.catapultState() = Scooter::Airframe::OFF_CAT;
			}
		}
	}

	printf( "Event In: %d\n", in.event_type );
	return true;
}


void ed_fm_cold_start()
{
	s_state->input.coldInit();
	s_state->fm.coldInit();
	s_state->airframe.coldInit();
	s_state->engine.coldInit();
	s_state->avionics.coldInit();
	s_state->state.coldInit();
	s_state->fuelSystem.coldInit();
	s_state->radar.coldInit();
}

void ed_fm_hot_start()
{
	s_state->input.hotInit();
	s_state->fm.hotInit();
	s_state->airframe.hotInit();
	s_state->engine.hotInit();
	s_state->avionics.hotInit();
	s_state->state.hotInit();
	s_state->fuelSystem.hotInit();
	s_state->radar.hotInit();
}

void ed_fm_hot_start_in_air()
{
	s_state->input.airborneInit();
	s_state->fm.airborneInit();
	s_state->airframe.airborneInit();
	s_state->engine.airborneInit();
	s_state->avionics.airborneInit();
	s_state->state.airborneInit();
	s_state->fuelSystem.airborneInit();
	s_state->radar.airborneInit();
}

void ed_fm_repair()
{
	s_state->airframe.resetDamage();
	Scooter::DamageProcessor::GetDamageProcessor().Repair();
}

bool ed_fm_need_to_be_repaired()
{
	return Scooter::DamageProcessor::GetDamageProcessor().NeedRepair();
}

void ed_fm_on_planned_failure( const char* failure )
{
	printf( "Planned Failure: %s", failure );
	Scooter::DamageProcessor::GetDamageProcessor().SetFailure( failure );
}

bool ed_fm_add_local_force_component( double & x,double &y,double &z,double & pos_x,double & pos_y,double & pos_z )
{

	if ( s_state->fm.getForces().empty() )
		return false;

	Force f = s_state->fm.getForces().back();
	s_state->fm.getForces().pop_back();

	x = f.force.x;
	y = f.force.y;
	z = f.force.z;

	pos_x = f.pos.x;
	pos_y = f.pos.y;
	pos_z = f.pos.z;

	return true;
}

bool ed_fm_add_global_force_component( double & x,double &y,double &z,double & pos_x,double & pos_y,double & pos_z )
{

	return false;
}

bool ed_fm_add_local_moment_component( double & x,double &y,double &z )
{
	return false;
}

bool ed_fm_add_global_moment_component( double & x,double &y,double &z )
{
	return false;
}

double ed_fm_get_shake_amplitude()
{
	return s_state->fm.getCockpitShake();
}

bool ed_fm_enable_debug_info()
{
	return false;
}

void ed_fm_suspension_feedback(int idx, const ed_fm_suspension_info* info)
{



	if ( idx == 0 )
	{
		s_state->airframe.SetNoseWheelGroundSpeed( info->wheel_speed_X );
		s_state->airframe.SetNoseWheelForce( info->acting_force[0], info->acting_force[1], info->acting_force[2] );
		s_state->airframe.SetNoseWheelForcePosition( info->acting_force_point[0], info->acting_force_point[1], info->acting_force_point[2] );

		//printf( "Force={%lf,%lf,%lf},Position={%lf,%lf,%lf}\n", info->acting_force[0], info->acting_force[1], info->acting_force[2], info->acting_force_point[0], info->acting_force_point[1], info->acting_force_point[2] );
		s_state->airframe.setNoseCompression( info->struct_compression );
	}

	if ( idx == 1 )
	{
		s_state->airframe.SetLeftWheelGroundSpeed( float(info->wheel_speed_X) );
		s_state->airframe.SetCompressionLeft( float(info->struct_compression) );
		/*printf( "wheel speed: %lf, force: %lf,%lf,%lf, point: %lf, %lf, %lf\n",
			info->wheel_speed_X,
			info->acting_force[0],
			info->acting_force[1],
			info->acting_force[2],
			info->acting_force_point[0],
			info->acting_force_point[1],
			info->acting_force_point[2] );*/


	}

	if ( idx == 2 )
	{
		s_state->airframe.SetRightWheelGroundSpeed( float(info->wheel_speed_X) );
		s_state->airframe.SetCompressionRight( float(info->struct_compression) );
	}

	if ( idx > 2 )
	{
		printf( "Something Else\n" );
	}
}

void ed_fm_set_plugin_data_install_path ( const char* path )
{
#ifdef LOGGING
	char logFile[200];
	sprintf_s( logFile, 200, "%s/efm_log.txt", path );
	fopen_s( &g_log, logFile, "a+" );
#endif
	printf( "%s\n", srcvers );

	LOG_BREAK();
	LOG( "Begin Log, %s\n", srcvers );
	LOG( "Initialising Components...\n" );

	init(path);
	LOG( "Safe: %d\n", g_safeToRun );

	checkCompatibility( path );
}

void ed_fm_configure ( const char* cfg_path )
{

}

void ed_fm_release ()
{
	cleanup();
	g_safeToRun = false;
#ifdef LOGGING
	LOG( "Releasing Components...\n" );
	LOG( "Closing Log...\n" );
	if ( g_log )
	{
		fclose( g_log );
		g_log = nullptr;
	}
#endif
}

bool ed_fm_LERX_vortex_update( unsigned idx, LERX_vortex& out )
{
	if ( idx < s_state->splines.size() )
	{
		out.opacity = s_state->splines[idx].getOpacity();//clamp((s_state->state.getAOA() - 0.07) / 0.174533, 0.0, 0.8);
		out.explosion_start = 10.0;
		out.spline = s_state->splines[idx].getArrayPointer();
		out.spline_points_count = int(s_state->splines[idx].size());
		out.spline_point_size_in_bytes = LERX_vortex_spline_point_size;
		out.version = 0;
		return true;
	}

	return false;
}

void ed_fm_set_immortal( bool value )
{
	if ( value )
		printf( "Nice try!\n" );
}

void ed_fm_unlimited_fuel( bool value )
{
	s_state->fuelSystem.setUnlimitedFuel(value);
}
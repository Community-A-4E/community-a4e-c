// FM_Verify.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
#include <FlightModel.h>
#include <stdio.h>
#include <Maths.h>
#include <Units.h>
#include <fstream>
#include <string>
#include <unordered_map>
#include <vector>

static Vec3 zero{ 0.0, 0.0, 0.0 };

struct Quaternion
{
    double w, x, y, z;
};

Quaternion ToQuaternion( double roll, double pitch, double yaw ) // roll (x), pitch (Y), yaw (z)
{
    // Abbreviations for the various angular functions

    double cr = cos( roll * 0.5 );
    double sr = sin( roll * 0.5 );
    double cp = cos( pitch * 0.5 );
    double sp = sin( pitch * 0.5 );
    double cy = cos( yaw * 0.5 );
    double sy = sin( yaw * 0.5 );

    Quaternion q;
    q.w = cr * cp * cy + sr * sp * sy;
    q.x = sr * cp * cy - cr * sp * sy;
    q.y = cr * sp * cy + sr * cp * sy;
    q.z = cr * cp * sy - sr * sp * cy;

    return q;
}

Vec3 UpFromQuat( Quaternion q )
{
    double x = q.x;
    double y = q.z;
    double z = q.y;
    double w = q.w;

    double y2 = y + y;
    double z2 = z + z;

    double yy = y * y2;
    double zz = z * z2;

    double xy = x * y2;
    double xz = x * z2;

    double wz = w * z2;
    double wy = w * y2;

    Vec3 globalUp;
    double x2 = x + x;
    double yz = y * z2;
    double wx = w * x2;

    double xx = x * x2;

    globalUp.x = xy + wz;
    globalUp.y = 1.0 - ( xx + zz );
    globalUp.z = yz - wx;

    return globalUp;
}

struct TacviewInfo
{
    std::string time;
    double relative_time = 0.0;
    double longitude = 0.0;
    double latitude = 0.0;
    double roll = 0.0;
    double pitch = 0.0;
    double yaw = 0.0;
    double true_airspeed = 0.0;
    double altitude = 0.0;
    double aoa = 0.0;
    double aos = 0.0;
    double g_force = 0.0;
    double long_g_force = 0.0;

    Vec3 GravityDirection() const 
    {
        Quaternion q = ToQuaternion( roll, pitch, 0.0 );
        return -UpFromQuat( q );
    }

    static double Convert( const std::string& s )
    {
        if ( s.empty() )
        {
            return 0.0;
        }

        return std::stod( s );
    }

    void FillData( std::unordered_map<std::string, std::vector<std::string>>& data, size_t index)
    {
        relative_time = Convert( data["Relative Time"][index] );
        true_airspeed = Convert( data["TAS"][index] );
        aoa = toRad( Convert( data["AOA"][index] ) );
        aos = toRad( Convert( data["AOS"][index] ) );
        altitude = Convert( data["ASL"][index] );
        g_force = Convert( data["G"][index] );
        long_g_force = Convert( data["LonG"][index] );
        roll = toRad( Convert( data["Roll"][index] ) );
        pitch = toRad( Convert( data["Pitch"][index] ) );
        yaw = toRad( Convert( data["Yaw"][index] ) );
        time = data["time"][index];

        std::size_t pos = time.find( "T" ) + 1;
        time = time.substr( pos );
    }

};

static std::vector<TacviewInfo> GetTacviewInfo(const char* filename)
{
    std::ifstream file( filename );

    std::string line;

    std::vector<std::string> strings;
    std::unordered_map<std::string, std::vector<std::string>> data;
    std::vector<std::string> headings;

    size_t index = 0;
    while ( std::getline(file, line) )
    {

        strings.emplace_back( "" );
        for ( size_t i = 0; i < line.size(); i++ )
        {
            if ( line[i] == ',' )
            {
                strings.emplace_back( "" );
            }
            else
            {
                strings.back().push_back( line[i] );
            }
        }

        if ( index == 0 )
        {
            headings = std::move(strings);
            headings[0] = "time";
        }
        else
        {
            for ( size_t i = 0; i < strings.size(); i++ )
            {
                const std::string& heading = headings[i];
                data[heading].push_back( strings[i] );
            }
        }
        strings.clear();
        index++;
    }

    file.close();

    std::vector<TacviewInfo> info;
    for ( size_t i = 0; i < index-1; i++ )
    {
        info.push_back( TacviewInfo{} );
        info.back().FillData(data, i);
    }


    return info;
}

class Aircraft
{
public:
    Aircraft(cockpit_param_api api):
        inter(api),
        engine(state),
        airframe(state,input,engine),
        flight_model(state,input,airframe,engine,inter, splines )
    {
        
    }

    Scooter::AircraftState state;
    Scooter::ParameterInterface inter;
    Scooter::Input input;
    Scooter::Engine2 engine;
    Scooter::Airframe airframe;
    Scooter::FlightModel flight_model;
    std::vector<LERX> splines;

    void Init();

    void SetFromTacview( const TacviewInfo& state );

    void Update( double dt );
    Vec3 force = { 0.0, 0.0, 0.0 };

};



void Aircraft::Init()
{
    input.airborneInit();
    flight_model.airborneInit();
    airframe.airborneInit();
    engine.airborneInit();
    state.airborneInit();

    airframe.setMass( 12000.0 );

    state.setSurface( 1000.0, { 0.0, 1.0, 0.0 } );
    
}

void Aircraft::SetFromTacview( const TacviewInfo& tacview_state )
{
    const Vec3 airspeed = { tacview_state.true_airspeed, 0.0, 0.0 };
    const Vec3 body_velocity = Scooter::windAxisToBody( airspeed, tacview_state.aoa, tacview_state.aos );
    state.setCurrentStateWorldAxis( { 0.0, 0.0, 0.0 }, body_velocity, { 1.0, 0.0, 0.0 }, { 0.0, -1.0, 0.0 } );
    state.setCurrentStateBodyAxis( tacview_state.aoa, 0.0, zero, zero, zero, body_velocity, body_velocity, zero );
    state.setCurrentAtmosphere( 293.0, 340.0, 1.23, 105000.0, zero );
}

void Aircraft::Update(double dt)
{
    engine.setThrottle( 1.0 );
    force = flight_model.getForce();
    //velocity.x += dt * force.x / airframe.getMass();
    //printf( "Force={%lf,%lf,%lf}, RPM=%lf\n", force.x, force.y, force.z, engine.getRPMNorm() );

    /*state.setSurface( 2000.0, Vec3( 0.0, 1.0, 0.0 ) );
    state.setCurrentStateWorldAxis( { 0.0, 0.0, 0.0 }, velocity, { 1.0, 0.0, 0.0 }, { 0.0, -1.0, 0.0 } );
    state.setCurrentStateBodyAxis( aoa, 0.0, zero, zero, zero, body_velocity, body_velocity, zero );
    state.setCurrentAtmosphere( 293.0, 340.0, 1.23, 105000.0, zero );*/

    input.update( false );
    engine.updateEngine( dt );
    airframe.airframeUpdate( dt );
    flight_model.calculateAero( dt );
    
}


static void* dummy_get_param_handle()
{
    return nullptr;
}

static void dummy_set_number(void* handle, double number)
{
    
}

int main()
{

    std::vector<TacviewInfo> info = GetTacviewInfo( "Tacview-20230416-204713-DCS-F5A4F1OcaStrike_V3.csv" );
    //std::vector<TacviewInfo> info = GetTacviewInfo( "Tacview-20230416-204713-DCS-F5A4F1OcaStrike_V3_Alex.csv" );
    //std::vector<TacviewInfo> info = GetTacviewInfo( "Tacview-20230416-204713-DCS-F5A4F1OcaStrike_V3_Mirage.csv" );


    cockpit_param_api api;
    memset( &api, 0, sizeof( cockpit_param_api ) );
    api.pfn_ed_cockpit_get_parameter_handle = (PFN_ED_COCKPIT_GET_PARAMETER_HANDLE)dummy_get_param_handle;
    api.pfn_ed_cockpit_update_parameter_with_number = (PFN_ED_COCKPIT_UPDATE_PARAMETER_WITH_NUMBER)dummy_set_number;

    Aircraft aircraft(api);
    aircraft.Init();

    static constexpr double runtime = 10.0;
    static constexpr double dt = 0.006;
    static constexpr auto max_steps = static_cast<size_t>( runtime / dt );

   /* for ( size_t steps = 0; steps < max_steps; steps++ )
    {
        aircraft.Update( dt );
    }*/

    bool issue_started = false;
    double time_start = 0.0;

    std::string error_message;

    for ( size_t i = 0; i < info.size(); i++ )
    {
        const TacviewInfo& tacview_state = info[i];
        aircraft.SetFromTacview( tacview_state );
        aircraft.Update( dt );

        if ( tacview_state.true_airspeed < 20.0 )
        {
            continue;
        }

        if ( tacview_state.true_airspeed > 300.0 )
        {
            int x = 10;
        }

        Vec3 gravity = tacview_state.GravityDirection();
        Vec3 acceleration_g = aircraft.force / (aircraft.airframe.getMass() * 9.81) +  gravity;

        //const double g_force = (aircraft.force.y / aircraft.airframe.getMass()) / 9.81;


        Vec3 tacview_g = { tacview_state.long_g_force, tacview_state.g_force, 0.0 };
        tacview_g += gravity;

        Vec3 fractional_error;

        fractional_error.x = tacview_g.x / acceleration_g.x;
        fractional_error.y = tacview_g.y / acceleration_g.y;

       // const double tac_max = g_force_tacview + error;

        const bool long_error = fractional_error.x > 1.0 && tacview_g.x > acceleration_g.x;
        const bool vert_error = fractional_error.y > 1.0 && tacview_g.y > acceleration_g.y + 1.0;
         
        const bool issue = vert_error || long_error;

        if ( issue_started != issue )
        {
            if ( issue )
            {
                time_start = tacview_state.relative_time;
                error_message = "";

                //printf( "=====================\n" );
            }
            else
            {
                const double deviation_time = tacview_state.relative_time - time_start;

                if ( deviation_time > 3.0 )
                {
                    printf( "%s", error_message.c_str() );
                    printf( "Total Deviation Time: %lf seconds\n", deviation_time );
                }
                error_message.clear();
            }
        }

        issue_started = issue;

        if ( issue_started )
        {
            const double time = tacview_state.relative_time / 60.0;
            double minutes = 0.0;
            const double seconds = modf( time, &minutes ) * 60.0;

            

            if ( error_message.size() < 400 )
            {

                if ( long_error )
                {
                    char buff[100];
                    //sprintf_s( buff, 100, "%s:\tExpected=%lf, Max Tolerance=%lf, Sim=%lf, Error Factor=%.02lf\n",  tacview_state.time.c_str(), g_force_tacview, tac_max, g_force, fractional_error );
                    sprintf_s( buff, 100, "(LONG ACCEL) %s: \tExpected=%lf, Tacview=%lf, Error Factor=%.02lf\n", tacview_state.time.c_str(), acceleration_g.x, tacview_g.x, fractional_error.x );
                    error_message += buff;
                }

                if ( vert_error )
                {
                    char buff[100];
                    //sprintf_s( buff, 100, "%s:\tExpected=%lf, Max Tolerance=%lf, Sim=%lf, Error Factor=%.02lf\n",  tacview_state.time.c_str(), g_force_tacview, tac_max, g_force, fractional_error );
                    sprintf_s( buff, 100, "(VERT ACCEL) %s: \tExpected=%lf, Tacview=%lf, Error Factor=%.02lf\n", tacview_state.time.c_str(), acceleration_g.y, tacview_g.y, fractional_error.y );
                    error_message += buff;
                }
                
            }

            //time=%.lf:%.02lf,
        }
    }

}
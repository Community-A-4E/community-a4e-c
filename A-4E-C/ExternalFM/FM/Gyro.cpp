#include "Gyro.h"
#include <stdio.h>
#define _USE_MATH_DEFINES
#include <math.h>
#include "cockpit_base_api.h"
#include "Units.h"

using namespace Scooter;

Gyro::Gyro( const Variables& variables ) :
    m_mass( variables.rotor_mass ),
    m_radius( variables.radius ),
    m_rpm_factor( variables.rpm_factor ),
    m_operating_omega( variables.operating_omega ),
    m_gimbal_friction(variables.gimbal_friction),
    m_erection_rate(variables.erection_rate),
    m_damping(variables.damping),
    m_slow_erection_factor(variables.slow_erection_factor)
{

    m_motor_damage = DamageProcessor::MakeDamageObject( variables.name + " Motor Damage", variables.damage_location, []( DamageObject& object, double integrity )
    {
        if ( integrity < 1.0 && DamageProcessor::GetDamageProcessor().Random() <= 0.25 )
        {
            object.SetIntegrity( 0.0 );
        }
    } );

    m_seized = DamageProcessor::MakeDamageObject( variables.name + " Motor Seized", variables.damage_location, []( DamageObject& object, double integrity )
    {
        if ( integrity < 1.0 && DamageProcessor::GetDamageProcessor().Random() <= 0.25 )
        {
            object.SetIntegrity( 0.0 );
        }
    } );

    DamageProcessor::AddRepairCallback( [this] { ColdStart(); } );


    const double angle = 2.0 * M_PI * DamageProcessor::GetDamageProcessor().Random();
    m_random_T_direction.x() = cos( angle );
    m_random_T_direction.y() = sin( angle );




    m_spin_down_time = variables.spin_down_time;
    m_spin_up_time = variables.spin_up_time;

    


    CalculateMomentOfInertia();
    SetBodyOmega( Vec3( 0.0, 0.0, 0.0 ) );
}

void Gyro::ColdStart()
{
    //Quat ident = Quat::Identity();
    const Eigen::AngleAxis<double> axis( 0.4, Vec3( 0.0, 1.0, 0.0 ) );
    Quat ident( axis );

    m_state.q0 = ident.w();
    m_state.q1 = ident.x();
    m_state.q2 = ident.y();
    m_state.q3 = ident.z();

    NormalizeQ();

    m_state.q0d = 0.0;
    m_state.q1d = 0.0;
    m_state.q2d = 0.0;
    m_state.q3d = 0.0;

    UpdateBodyTransform();
}

void Gyro::HotStart()
{
    ColdStart();
    Quat ident = Quat::Identity();
    m_state.q0 = ident.w();
    m_state.q1 = ident.x();
    m_state.q2 = ident.y();
    m_state.q3 = ident.z();

    m_w.z() = m_operating_omega / m_rpm_factor;

    m_motor_on = true;
    m_electrical_power = true;

    SetBodyOmega( m_w );
}

double Gyro::GyroError( const Vec3& reference ) const
{
    const Vec3 up = { 0.0, 0.0, 1.0 };
    Vec3 reference_body = m_to_body * reference;
    const double cosa = reference_body.normalized().dot( up );
    const double a = acos( cosa );
    return a;
}

void Gyro::CalculateErectionTorque( const Quat& world_orientation )
{
    m_erection_direction = -(m_world_acceleration + Vec3{ 0.0, 0.0, -9.81 });
    m_erection_direction.normalize();

    // y = 1, with up_body x up
    const Vec3 forwards = { 1.0, 0.0, 0.0 };
    const Vec3 up = m_erection_direction;

    const Vec3 right = forwards.cross( up );
    const Vec3 right_body = m_to_body * right;

    const double percent_spin_up = PercentSpinUp();
    const Vec3 torque = right_body.cross( right );

   
    if ( GyroError( up ) < 0.01_deg && percent_spin_up > 0.95 )
        m_fast_erect = false;


    double erection_rate = m_erection_rate;
    double erection_max_torque = m_max_erection_torque;

    if ( ! m_fast_erect )
    {
        erection_rate *= m_slow_erection_factor;
        //erection_max_torque *= slow_erect_factor;
    }

    //m_erection_T = erection_rate * torque.normalized();// ( GyroError( up ) + 1.0 );
    //m_erection_T.z() = 0.0;

    //m_erection_T = ( Vec3{ 1.0_deg, 0.0, 0.0 } - m_w ) * m_erection_rate;

    // Rate of Gyro Erection should be constant.
    // This means the error is decreasing linearly.
    // dot(gyro_up, up)
    //

    // Vec3 gyro_up = m_to_body.inverse() * Vec3 { 0.0, 0.0, 1.0 };
    // Vec3 force_direction = m_erection_direction.cross( gyro_up );
    // Vec3 torque2 = force_direction.cross( gyro_up );


    // m_erection_T = (m_to_body * torque2) * erection_rate;//( torque2.normalized() - m_w ) / ( GyroError(up) + 0.01_deg );



    m_erection_T = torque * erection_rate * percent_spin_up * percent_spin_up / (GyroError( up ) + 1.0);



    //m_erection_T = torque * erection_rate * 1.0_deg * percent_spin_up;
    m_erection_T.z() = 0.0;

    const double torque_scalar = std::min( m_erection_T.norm(), erection_max_torque );
    m_erection_T.normalize();
    m_erection_T *= torque_scalar;

}

void Gyro::GetPitchRoll( double& pitch, double& roll ) const
{
    Quat rotation =  m_world_orientation  * m_to_body; //m_to_body.inverse() *
    const Mat3 rotation_matrix = rotation.toRotationMatrix();
    Vec3 angles = rotation_matrix.canonicalEulerAngles( 0, 1, 2 );

    roll = 180.0 * angles.x() / M_PI;
    pitch = 180.0 * angles.y() / M_PI;
}

void Gyro::CalculateMomentOfInertia()
{
    const double symetric_I = m_mass * m_radius * m_radius;
    m_I.z() = symetric_I * m_rpm_factor;


    m_I.x() = symetric_I / 2.0;
    m_I.y() = symetric_I / 2.0;
}

void Gyro::UpdateVectors()
{
    m_w = GetOmegaFromState( m_state );
    m_L.x() = m_I.x() * m_w.x();
    m_L.y() = m_I.y() * m_w.y();
    m_L.z() = m_I.z() * m_w.z();

    UpdateBodyTransform();
}

void Gyro::UpdateBodyTransform()
{
    m_to_body.w() = m_state.q0;
    m_to_body.x() = m_state.q1;
    m_to_body.y() = m_state.q2;
    m_to_body.z() = m_state.q3;
}


Gyro::Vec3 Gyro::GetOmegaFromState( const State& state )
{
    const double q0 = state.q0;
    const double q1 = state.q1;
    const double q2 = state.q2;
    const double q3 = state.q3;

    // dq/dt
    const double q0d = state.q0d;
    const double q1d = state.q1d;
    const double q2d = state.q2d;
    const double q3d = state.q3d;

    Vec3 result;

    result.x() = 2.0 * ( -q1 * q0d + q0 * q1d + q3 * q2d - q2 * q3d );
    result.y() = 2.0 * ( -q2 * q0d - q3 * q1d + q0 * q2d + q1 * q3d );
    result.z() = 2.0 * ( -q3 * q0d + q2 * q1d - q1 * q2d + q0 * q3d );

    return result;
}

Gyro::Quat Gyro::GetdQFromOmega( const Vec3& omega )
{
    Quat result;

    const double q0 = m_state.q0;
    const double q1 = m_state.q1;
    const double q2 = m_state.q2;
    const double q3 = m_state.q3;

    const double wx = omega.x();
    const double wy = omega.y();
    const double wz = omega.z();

    result.w() = 0.5 * ( -q1 * wx - q2 * wy - q3 * wz );
    result.x() = 0.5 * ( q0 * wx - q3 * wy + q2 * wz );
    result.y() = 0.5 * ( q3 * wx + q0 * wy - q1 * wz );
    result.z() = 0.5 * ( -q2 * wx + q1 * wy + q0 * wz );

    return result;
}

void Gyro::SetBodyOmega( const Vec3& omega )
{
    Quat dQ = GetdQFromOmega( omega );
    m_state.q0d = dQ.w();
    m_state.q1d = dQ.x();
    m_state.q2d = dQ.y();
    m_state.q3d = dQ.z();

    UpdateVectors();
}

void Gyro::NormalizeQ()
{

    const double sum_sqr = m_state.q0 * m_state.q0 +
        m_state.q1 * m_state.q1 +
        m_state.q2 * m_state.q2 +
        m_state.q3 * m_state.q3;

    const double sum = sqrt( sum_sqr );

    if ( sum == 0.0 )
        return;

    m_state.q0 /= sum;
    m_state.q1 /= sum;
    m_state.q2 /= sum;
    m_state.q3 /= sum;

}

void Gyro::Update( double dt, const Quat& world_orientation, const Vec3& local_acceleration, const Vec3& local_omega )
{
    m_world_orientation = world_orientation;
    m_world_acceleration = world_orientation * local_acceleration;
    m_gimbal_w = world_orientation * local_omega;

    if ( ! m_electrical_power )
        m_fast_erect = true;


    static constexpr size_t sub_step_quantity = 1000;
    static constexpr double sub_step_quantity_f = static_cast<double>( sub_step_quantity );
    const double sub_step_dt = dt / sub_step_quantity_f;

    for ( size_t i = 0; i < sub_step_quantity; i++ )
    {
        Solve( sub_step_dt );
        // solver.step();

        NormalizeQ();
        UpdateVectors();


        //Vec3 up{ 0.0, 0.0, 1.0 };

        //Vec3 up_lab = m_to_body * up;
        //printf( "%.02lf,%.02lf %.02lf | %.02lf,%.02lf %.02lf\n", up_lab.x(), up_lab.y(), up_lab.z(), m_L.x(), m_L.y(), m_L.z() );
    }
}

void Gyro::ComputeBodyFrameTorque( const State& state )
{
    CalculateErectionTorque(Quat{});

    const double adjusted_operating_omega = m_operating_omega / m_rpm_factor;

    // ln(R) / (-t) = coeff
    // where R is the fraction from operating
    // and t is the time
    const double R = 0.5;
    m_spinning_friction = -log( R ) / m_spin_down_time;



    const double eta = exp( -m_spin_up_time * m_spinning_friction );
    m_spin_up_torque = m_spinning_friction * adjusted_operating_omega * ( R * eta - 1.0 ) / ( eta - 1.0 );




    const bool spin_up = PercentSpinUp() < 1.0;

    const double motor_torque_scalar = spin_up ? m_spin_up_torque : m_spinning_friction;
    const bool motor = m_motor_on && m_electrical_power && m_motor_damage->GetIntegrity() > 0.0;
    const Vec3 motor_torque = { 0.0, 0.0, motor_torque_scalar * static_cast<double>( motor ) };


    

    const Vec3 random_torque = m_random_T_direction * m_random_T * PercentSpinUp();

    Vec3 omega_aircraft = m_to_body * m_gimbal_w;
    omega_aircraft.z() /= m_rpm_factor;

    const Vec3 relative_omega = omega_aircraft + m_w; // technically we need to convert the omega aircraft.z to 
    Vec3 friction_torque;
    friction_torque.x() = relative_omega.x() * m_gimbal_friction;
    friction_torque.y() = relative_omega.y() * m_gimbal_friction;
    friction_torque.z() = relative_omega.z() * m_spinning_friction;


    const Vec3 damping_torque = m_w * m_damping;



    Vec3 static_friction_torque;
    static_friction_torque.x() = copysign( m_gimbal_static_friction, relative_omega.x() );
    static_friction_torque.y() = copysign( m_gimbal_static_friction, relative_omega.y() );
    static_friction_torque.z() = 0.0;

    m_T = m_erection_T + motor_torque - damping_torque - friction_torque + random_torque - static_friction_torque + m_to_body * m_debug_torque;


    /*Vec3 down{ 0.0, 0.0, 1.0 };

    Vec3 force = m_to_body * down;

    m_T.x() = force.y();
    m_T.y() = force.x();
    m_T.z() = 0.0;*/
}


void Gyro::ComputeBodyFrameAcceleration( const State& state )
{
    const Vec3 omega = GetOmegaFromState( state );
    ComputeBodyFrameTorque( state );


    const double I1 = m_I.x();
    const double I2 = m_I.y();
    const double I3 = m_I.z();

    const double T1 = m_T.x();
    const double T2 = m_T.y();
    const double T3 = m_T.z();

    const double wx = 0.0; //omega.x();
    const double wy = 0.0; //omega.y();
    const double wz = 0.0; //omega.z();

    m_w_dot.x() = ( T1 - ( I3 - I2 ) * wx * wy ) / I1;
    m_w_dot.y() = ( T2 - ( I1 - I3 ) * wx * wz ) / I2;
    m_w_dot.z() = ( T3 - ( I2 - I1 ) * wy * wx ) / I3;
}

void Gyro::GetRate( const State& state, Rate& rate )
{
    ComputeBodyFrameAcceleration( state );

    double sum = state.q0d * state.q0d + state.q1d * state.q1d + state.q2d * state.q2d + state.q3d * state.q3d;
    sum = -2.0 * sum;

    const double q0 = state.q0;
    const double q1 = state.q1;
    const double q2 = state.q2;
    const double q3 = state.q3;

    // dq/dt
    const double q0d = state.q0d;
    const double q1d = state.q1d;
    const double q2d = state.q2d;
    const double q3d = state.q3d;

    rate.q0d = q0d;
    rate.q1d = q1d;
    rate.q2d = q2d;
    rate.q3d = q3d;

    const double wxdot = m_w_dot.x();
    const double wydot = m_w_dot.y();
    const double wzdot = m_w_dot.z();

    rate.q0dd = 0.5 * ( -q1 * wxdot - q2 * wydot - q3 * wzdot + q0 * sum );
    rate.q1dd = 0.5 * ( q0 * wxdot - q3 * wydot + q2 * wzdot + q1 * sum );
    rate.q2dd = 0.5 * ( q3 * wxdot + q0 * wydot - q1 * wzdot + q2 * sum );
    rate.q3dd = 0.5 * ( -q2 * wxdot + q1 * wydot + q0 * wzdot + q3 * sum );
    rate.t = 1.0;

}

void Gyro::Solve( double dt )
{

    Rate rate;

    GetRate( m_state, rate );


    m_state.q0d += dt * rate.q0dd;
    m_state.q1d += dt * rate.q1dd;
    m_state.q2d += dt * rate.q2dd;
    m_state.q3d += dt * rate.q3dd;

    // earth_dQ
    /*const double earth_drift_rate = 360.0_deg / 24.0_hours;

    Vec3 earth_drift = { earth_drift_rate, 0.0, 0.0 };
    Quat earth_drift_dQ = GetdQFromOmega( m_to_body * earth_drift );*/

    /*+ earth_drift_dQ.w()
        + earth_drift_dQ.x()
        + earth_drift_dQ.y()
        + earth_drift_dQ.z()*/

    const double integrity = m_seized->GetIntegrity();

    m_state.q0 += dt * ( rate.q0d * integrity );
    m_state.q1 += dt * ( rate.q1d * integrity );
    m_state.q2 += dt * ( rate.q2d * integrity );
    m_state.q3 += dt * ( rate.q3d * integrity );
}

//void Gyro::ImguiDebugWindow()
//{
//    double pitch = 0.0;
//    double roll = 0.0;
//    GetPitchRoll( pitch, roll );
//    ImGui::Text( "Pitch: %lf", pitch );
//    ImGui::Text( "Roll: %lf", roll );
//
//
//    ImGui::Text( "Gyro Error: %lf", GyroError( m_erection_direction ) / 1.0_deg );
//    ImGui::Text( "Gyro Real Error: %lf", GyroError( Vec3{ 0.0, 0.0, 1.0 } ) / 1.0_deg );
//
//    Quat to_body = GetToBody();
//    Quat from_body = to_body.inverse();
//
//    Vec3 up = { 0.0, 0.0, 1.0 };
//    Vec3 up_body = to_body * up;
//    Vec3 up_lab = from_body * up;
//
//    ImGui::Text( "Erection Direction: %.04lf,%.04lf,%.04lf", m_erection_direction.x(), m_erection_direction.y(), m_erection_direction.z() );
//    ImGui::Text( "Up (Gyro) Body: %.04lf,%.04lf,%.04lf", up_body.x(), up_body.y(), up_body.z() );
//    ImGui::Text( "Up Lab: %.04lf,%.04lf,%.04lf", up_lab.x(), up_lab.y(), up_lab.z() );
//
//
//    Quat q = m_world_orientation * GetToBody();
//    Vec3 up_local = q * Vec3{ 0.0, 0.0, 1.0 };
//
//    ImGui::Text( "Up (Aircraft) Body: %.02lf,%.02lf,%.02lf", up_local.x(), up_local.y(), up_local.z() );
//
//
//    ImGui::SliderFloat( "Set Spin Velocity", &m_gyro_debug_w, 0.0, 48000.0 );
//    ImGui::SliderFloat( "Set Gyro Tickle Velocity", &m_gyro_tickle_debug_w, 0.0, 720.0 );
//
//
//    const double tickle_rate = static_cast<double>( m_gyro_tickle_debug_w ) * M_PI / 180.0;
//
//    if ( m_motor_on )
//    {
//        if ( ImGui::Button( "Turn Motor Off" ) )
//        {
//            m_motor_on = false;
//        }
//    }
//    else
//    {
//        if ( ImGui::Button( "Turn Motor On" ) )
//        {
//            m_motor_on = true;
//        }
//    }
//
//    if ( m_fast_erect )
//    {
//        if ( ImGui::Button( "Fast Erect Stop" ) )
//        {
//            m_fast_erect = false;
//        }
//    }
//    else
//    {
//        if ( ImGui::Button( "Fast Erect Start" ) )
//        {
//            m_fast_erect = true;
//        }
//    }
//
//    if ( ImGui::Button( "Set wx" ) )
//    {
//
//        SetBodyOmegaX( tickle_rate );
//    }
//
//    if ( ImGui::Button( "Set wy" ) )
//    {
//        SetBodyOmegaY( tickle_rate );
//    }
//
//    if ( ImGui::Button( "Set wz" ) )
//    {
//        const double angle = static_cast<double>( m_gyro_debug_w ) * M_PI / 180.0;
//        SetBodyOmegaZ( angle );
//    }
//
//    ImGui::Text( "Operating Omega: %lf", m_operating_omega );
//    ImGui::InputDouble( "Gimbal Friction", &m_gimbal_friction, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Gimbal Static Friction", &m_gimbal_static_friction, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Gimbal Erection Rate", &m_erection_rate, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Gimbal Damping", &m_damping, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Max Erection Torque", &m_max_erection_torque, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Slow Erection Factor", &m_slow_erection_factor, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Erection Friction", &m_erection_friction, 0.00001, 0.01, "%.8f" );
//    ImGui::InputDouble( "Random Torque", &m_random_T, 0.00001, 0.01, "%.8f" );
//
//
//    if ( ImGui::TreeNode("Debug Torque") )
//    {
//        ImGui::InputDouble( "Debug Torque X", &m_debug_torque.x(), 0.00001, 0.01, "%.8f" );
//        ImGui::InputDouble( "Debug Torque Y", &m_debug_torque.y(), 0.00001, 0.01, "%.8f" );
//        ImGui::InputDouble( "Debug Torque Z", &m_debug_torque.z(), 0.00001, 0.01, "%.8f" );
//        ImGui::TreePop();
//    }
//   
//
//
//    ImGui::InputDouble( "Spin Up Time (seconds)", &m_spin_up_time, 1.0, 10.0, "%.0f" );
//    ImGui::InputDouble( "Spin Down Time (seconds)", &m_spin_down_time, 1.0, 10.0, "%.0f" );
//
//    ImGui::Text( "Gimbal Torque:  %.05lf,%.05lf,%.05lf", GetTorque().x(), GetTorque().y(), GetTorque().z() );
//    ImGui::Text( "Erection Torque:  %.05lf,%.05lf,%.05lf",m_erection_T.x(), m_erection_T.y(), m_erection_T.z() );
//    ImGui::Text( "Random Torque Direction:  %.05lf,%.05lf,%.05lf",m_random_T_direction.x(), m_random_T_direction.y(), m_random_T_direction.z() );
//
//    Vec3 gyro_omega = GetRealOmega();
//    ImGui::Text( "Gimbal Omega:  %.05lf,%.05lf,%.0lf", gyro_omega.x(), gyro_omega.y(), gyro_omega.z() );
//}

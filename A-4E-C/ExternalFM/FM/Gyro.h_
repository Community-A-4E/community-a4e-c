#pragma once
#include <Eigen/Geometry>
#include "Damage.h"
#include "Units.h"

class Gyro
{
public:

    struct Variables
    {

        double rotor_mass = 1.0;
        double radius = 0.5;
        double rpm_factor = 1.0;
        double operating_omega = 48000.0_deg;
        DamageCell damage_location = DamageCell::FUSELAGE_LEFT_SIDE;
        std::string name = "Gyro_1";
        double gimbal_friction = 0.001;
        double damping = 0.01;
        double erection_rate = 0.001;
        double slow_erection_factor = 0.01;
        double random_torque = 0.0;
        double spin_down_time = 40.0;
        double spin_up_time = 60.0;
    };

    using Quat = Eigen::Quaternion<double>;
    using Mat3 = Eigen::Matrix3d;
    using Vec3 = Eigen::Vector3<double>;

    Gyro( const Variables& variables );

    void ColdStart();
    void HotStart();

    // Returns pitch and Roll in degrees
    void GetPitchRoll( double& pitch, double& roll ) const;
    void Update( double dt, const Quat& world_orientation, const Vec3& local_acceleration, const Vec3& local_omega );
    double GyroError( const Vec3& reference ) const;

    bool FastErect() const { return m_fast_erect; }
    bool Operating() const { return m_electrical_power; }
    double PercentSpinUp() const { return m_w.z() * m_rpm_factor / m_operating_omega; }

    void SetElectricalPower( bool value ) { m_electrical_power = value; }

    Quat GetToBody() { return m_to_body; }

    void SetBodyOmega( const Vec3& omega );


    void SetBodyOmegaX( double x ) { m_w.x() = x; SetBodyOmega( m_w ); }
    void SetBodyOmegaY( double y ) { m_w.y() = y; SetBodyOmega( m_w ); }

    void SetBodyOmegaZ( double z ) { m_w.z() = z / m_rpm_factor; SetBodyOmega( m_w ); }

    void CalculateErectionTorque( const Quat& world_orientation );
    void SetGimbalOmega( const Vec3& gimbal_omega ) { m_gimbal_w = gimbal_omega; }

    Vec3 GetTorque() const { return m_T; }
    Vec3 GetOmega() const { return m_w; }
    Vec3 GetRealOmega() const
    {
        Vec3 omega = m_w;
        omega.z() *= m_rpm_factor;
        return omega;
    }

    void ImguiDebugWindow();

    

private:

    std::shared_ptr<Scooter::DamageObject> m_motor_damage = nullptr;
    std::shared_ptr<Scooter::DamageObject> m_seized = nullptr;

    union State
    {
        double state[8];

        struct
        {
            double q0;
            double q0d;
            double q1;
            double q1d;
            double q2;
            double q2d;
            double q3;
            double q3d;
        };
    };

    union Rate
    {
        double rate[9];
        struct
        {
            double q0d;
            double q0dd;
            double q1d;
            double q1dd;
            double q2d;
            double q2dd;
            double q3d;
            double q3dd;
            double q4d;
            double q4dd;
            double t;
        };
    };

    Quat GetdQFromOmega( const Vec3& omega );
    void Solve( double dt );
    void NormalizeQ();

    State m_state;
    void GetRate( const State& state, Rate& rate );
    void CalculateMomentOfInertia();
    void ComputeBodyFrameTorque( const State& state );
    void ComputeBodyFrameAcceleration( const State& state );

    Vec3 GetOmegaFromState( const State& state );

    void UpdateBodyTransform();
    void UpdateVectors();
    
    

    const double m_mass = 1.0;
    const double m_radius = 0.5;
    const double m_rpm_factor = 1.0; 

    
    double m_operating_omega = 0.0;

    // From Book
    Quat m_to_body{0.0, 0.0, 0.0, 0.0}; // Rotation of Body in Lab frame.
    Vec3 m_w{0.0, 0.0, 0.0}; // Angular Velocity Body Frame
    Vec3 m_w_dot{0.0, 0.0, 0.0}; // Angular Velocity Body Frame
    Vec3 m_T{0.0, 0.0, 0.0}; // Torque

   
    Vec3 m_gimbal_w{ 0.0, 0.0, 0.0 };//


    Vec3 m_L{0.0, 0.0, 0.0}; // Momentum Body Frame

    Vec3 m_L_world{0.0, 0.0, 0.0}; // Momentum World Frame

    Vec3 m_I; // Diagonal Moment of Inertia (Body frame)

    Quat m_world_orientation = Quat::Identity();
    Vec3 m_world_acceleration{0.0, 0.0, 0.0};
    
    bool m_fast_erect = true;

    bool m_electrical_power = false;
    bool m_motor_on = true;
    double m_gimbal_friction = 1e-4; //x,y torque
    double m_gimbal_static_friction = 0.0; //x,y torque
    double m_damping = 0.0;

    double m_spinning_friction = 0.0;
    double m_spin_down_time = 40.0;//seconds
    double m_spin_up_time = 60.0;//seconds
    double m_spin_up_torque = 1.0;


    double m_erection_rate = 1.0;
    double m_slow_erection_factor = 0.01;
    double m_erection_friction = 1.0;
    double m_max_erection_torque = 0.1;
    Vec3 m_erection_direction{ 0.0, 0.0, 1.0 };
    Vec3 m_erection_T{ 0.0, 0.0, 0.0 };


    double m_random_T = 0.0;
    Vec3 m_random_T_direction{ 0.0, 0.0, 0.0 };

    float m_gyro_debug_w = 0.0;
    float m_gyro_tickle_debug_w = 0.0;
    Vec3 m_debug_torque = {0.0, 0.0, 0.0};
};
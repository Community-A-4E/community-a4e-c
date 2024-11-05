#pragma once
#include <functional>
#include <unordered_map>
#include <vector>
#include "Interface.h"
#include "DamageCells.h"
#include <string>
#include <random>
#include <Common/Maths.h>
namespace Scooter
{
    class DamageObject
    {
    public:
        DamageObject( const std::string&& name );
        void Repair() { SetIntegrity( 1.0 ); }
        [[nodiscard]] double GetIntegrity() const { return m_integrity; }
        [[nodiscard]] double GetDamage() const { return 1.0 - m_integrity; }
        void Damage( double integrity );
        const std::string& GetName() const { return m_name; }
        void SetDamageCallback( std::function<void( DamageObject&, double )> callback ) { m_on_damage = callback; }
        void SetUpdateHandle( std::function<void( double )> callback ) { m_update_handle = callback; }
        void SetIntegrity( double integrity )
        {
            integrity = clamp( integrity, 0.0, 1.0 );
            m_integrity = integrity;
            if ( m_integrity != integrity )
            {
                LOG_DAMAGE( "DamageObject<%s>|%lf\n", m_name.c_str(), m_integrity );
            }
            if ( m_update_handle )
            {
                m_update_handle( integrity );
            }
        }
    private:
        double m_integrity = 1.0;
        const std::string m_name;
        std::function<void( double )> m_update_handle = nullptr;
        std::function<void( DamageObject&, double )> m_on_damage = nullptr;
    };


    class DamageProcessor
    {
    public:

        DamageProcessor( Interface& inter );

        static DamageProcessor& GetDamageProcessor()
        {
            return *m_damage_processor;
        }

        static void Create( Interface& inter )
        {
            m_damage_processor = std::make_unique<DamageProcessor>( inter );
        }

        static void Destroy()
        {
            m_damage_processor = nullptr;
        }

        static void AddRepairCallback( std::function<void()>&& repair_callback );
        static std::shared_ptr<DamageObject> MakeDamageObject( const std::string&& name, DamageCell cell, std::function<void(DamageObject&,double)> on_damage_handle = nullptr );
        static std::shared_ptr<DamageObject> MakeDamageObjectMultiple( const std::string&& name, const std::vector<DamageCell>& cells, std::function<void(DamageObject&,double)> on_damage_handle = nullptr );
        void SetupObject( DamageObject& object, std::function<void( DamageObject&, double )> on_damage_handle );

        void AddCallback( std::function<void()>&& repair_callback );
        void RegisterDamageObject( int cell, std::shared_ptr<DamageObject> object );
        void OnDamage( int cell, double integrity );
        bool NeedRepair() const;
        void Repair();
        void SetParameter( void* handle, double value ) const { m_interface.setParamNumber( handle, value ); }
        [[nodiscard]] double Random() { return distribution( generator ); }

        void SetFailure( const std::string& failure );
        void SetFailure( const std::string& failure, double integrity );

    private:

        void ImGuiDebugWindow();

        std::vector<std::function<void()>> m_damage_callbacks;
        std::unordered_map<std::string, std::weak_ptr<DamageObject>> m_objects_by_name;
        std::unordered_map<int, std::vector<std::weak_ptr<DamageObject>>> m_damage_objects;
        Interface& m_interface;
        static std::unique_ptr<DamageProcessor> m_damage_processor;
        std::uniform_real_distribution<double> distribution{ 0.0, 1.0 };
        std::mt19937 generator{ 4 };
    };
}


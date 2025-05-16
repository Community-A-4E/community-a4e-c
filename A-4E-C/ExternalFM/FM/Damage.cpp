#include "Damage.h"
//#include <LuaImGui.h>

std::unique_ptr<Scooter::DamageProcessor> Scooter::DamageProcessor::m_damage_processor = nullptr;

Scooter::DamageProcessor::DamageProcessor( ParameterInterface& inter ) : m_interface( inter )
{
    /*LuaImGui::AddImGuiItem( "Airframe", "Damage", [this]() {
        ImGuiDebugWindow();
    } );*/
}


void Scooter::DamageProcessor::OnDamage( int cell, double integrity )
{
    const auto it = m_damage_objects.find( cell );
    if ( it != m_damage_objects.end() )
    {
        for ( auto& object : it->second )
        {
            if ( const std::shared_ptr<DamageObject> obj = object.lock(); obj )
            {
                obj->Damage( integrity );
            }
        }
    }
}

void Scooter::DamageProcessor::AddCallback( std::function<void()>&& repair_callback )
{
    m_damage_callbacks.push_back( std::move( repair_callback ) );
}

void Scooter::DamageProcessor::RegisterDamageObject( int cell, std::shared_ptr<DamageObject> object )
{
    const std::weak_ptr weak_object = object;
    m_damage_objects[cell].push_back( weak_object );
    m_objects_by_name[object->GetName()] = weak_object;
    object->Repair();
}

void Scooter::DamageProcessor::Repair()
{
    for ( auto& [cell, cell_objects] : m_damage_objects )
    {
        for ( auto& object : cell_objects )
        {
            if ( const std::shared_ptr<DamageObject> obj = object.lock(); obj )
            {
                obj->Repair();
            }
        }
    }

    for ( auto& function : m_damage_callbacks )
    {
        if ( function )
            function();
    }
}

bool Scooter::DamageProcessor::NeedRepair() const
{
    for ( auto& [cell, cell_objects] : m_damage_objects )
    {
        for ( auto& object : cell_objects )
        {
            if ( const std::shared_ptr<DamageObject> obj = object.lock(); obj )
            {
                if ( obj->GetIntegrity() < 1.0 )
                {
                    return true;
                }
            }
        }
    }

    return false;
}

void Scooter::DamageProcessor::SetFailure( const std::string& failure )
{
    SetFailure( failure, 0.0 );
}

void Scooter::DamageProcessor::SetFailure( const std::string& failure, double integrity )
{
    if ( const auto it = m_objects_by_name.find( failure ); it != m_objects_by_name.end() )
    {
        if ( const std::shared_ptr<DamageObject> object = it->second.lock(); object )
        {
            object->Damage( integrity );
        }
    }
}

void Scooter::DamageProcessor::SetupObject( DamageObject& object, std::function<void( DamageObject&, double )> on_damage_handle )
{
    const std::string handle_name = "DamageObject<" + object.GetName() + ">";
    void* handle = m_interface.api().pfn_ed_cockpit_get_parameter_handle( handle_name.c_str() );
    const std::function update_handle = [param_handle = handle]( double integrity )
    {
        GetDamageProcessor().SetParameter( param_handle, integrity );
    };
    object.SetUpdateHandle( update_handle );

    if ( on_damage_handle )
    {
        object.SetDamageCallback( on_damage_handle );
    }
}

std::shared_ptr<Scooter::DamageObject> Scooter::DamageProcessor::MakeDamageObjectMultiple( const std::string&& name, const std::vector<DamageCell>& cells, std::function<void( DamageObject&, double )> on_damage_handle )
{
    const std::shared_ptr object = std::make_shared<DamageObject>( std::move( name ) );
    DamageProcessor& damage_processor = GetDamageProcessor();
    damage_processor.SetupObject( *object, on_damage_handle );

    const std::string handle_name = "DamageObject<" + object->GetName() + ">";
    LOG_DAMAGE( "%s: { ", handle_name.c_str() );

    for ( auto cell : cells )
    {
        LOG_DAMAGE( "%d ", cell );
        damage_processor.RegisterDamageObject( static_cast<int>( cell ), object );
    }

    LOG_DAMAGE( "}\n" );

    return object;
}

std::shared_ptr<Scooter::DamageObject> Scooter::DamageProcessor::MakeDamageObject( const std::string&& name, DamageCell cell, std::function<void( DamageObject&, double )> on_damage_handle )
{
    const std::shared_ptr object = std::make_shared<DamageObject>( std::move( name ) );
    DamageProcessor& damage_processor = GetDamageProcessor();
    damage_processor.SetupObject( *object, on_damage_handle );
    damage_processor.RegisterDamageObject( static_cast<int>( cell ), object );

    const std::string handle_name = "DamageObject<" + object->GetName() + ">";
    LOG_DAMAGE( "%s: { %d }\n", handle_name.c_str(), cell );

    return object;
}

void Scooter::DamageProcessor::AddRepairCallback(std::function<void()>&& repair_callback)
{
    DamageProcessor& damage_processor = GetDamageProcessor();
    damage_processor.AddCallback( std::move( repair_callback ) );
}

Scooter::DamageObject::DamageObject( const std::string&& name ):
    m_name(name)
{
}


void Scooter::DamageObject::Damage( double integrity )
{

    if ( integrity <= 0.0 )
    {
        SetIntegrity( 0.0 );
    }

    // Only make it worse, if we set from elsewhere then it won't magically get better
    // if you take damage.
    if ( m_on_damage )
    {
        m_on_damage( *this, integrity );
    }
    else if ( integrity < m_integrity )
    {
        SetIntegrity( integrity );
    }
}

void Scooter::DamageProcessor::ImGuiDebugWindow()
{
    /*if ( ImGui::TreeNode( "Damage Cells" ) )
    {
        for ( auto& [cell, objects] : m_damage_objects )
        {
            std::string damage_cell = "Damage Cell " + std::to_string( cell );

            if ( ImGui::TreeNode( damage_cell.c_str() ) )
            {
                const ImGuiTableFlags flags = ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg;
                if ( ImGui::BeginTable( "Damage Items", 2, flags ) )
                {

                    ImGui::TableSetupColumn( "Name" );
                    ImGui::TableSetupColumn( "Integrity" );
                    ImGui::TableHeadersRow();

                    for ( auto& object : objects )
                    {
                        ImGui::TableNextRow();
                        if ( auto object_ptr = object.lock(); object_ptr )
                        {
                            ImGui::TableSetColumnIndex( 0 );
                            ImGui::Text( "%s", object_ptr->GetName().c_str() );
                            ImGui::TableSetColumnIndex( 1 );
                            ImGui::Text( "%lf", object_ptr->GetIntegrity() );
                        }


                    }
                    ImGui::EndTable();
                }

                ImGui::TreePop();
            }
        }

        ImGui::TreePop();
    }

    if ( ImGui::TreeNode( "Damage Objects" ) )
    {
        const ImGuiTableFlags flags = ImGuiTableFlags_Borders | ImGuiTableFlags_RowBg;
        if ( ImGui::BeginTable( "Damage Items", 3, flags ) )
        {
            ImGui::TableSetupColumn( "Name" );
            ImGui::TableSetupColumn( "Integrity" );
            ImGui::TableSetupColumn( "Repair" );
            ImGui::TableHeadersRow();

            for ( auto& [name, object] : m_objects_by_name )
            {
                ImGui::TableNextRow();
                if ( auto object_ptr = object.lock(); object_ptr )
                {
                    ImGui::TableSetColumnIndex( 0 );
                    ImGui::Text( "%s", object_ptr->GetName().c_str() );
                    ImGui::TableSetColumnIndex( 1 );
                    ImGui::Text( "%lf", object_ptr->GetIntegrity() );
                    ImGui::TableSetColumnIndex( 2 );
                    if ( ImGui::Button("Repair") )
                    {
                        object_ptr->Repair();
                    }
                }
            }
            ImGui::EndTable();
        }
    }*/
}





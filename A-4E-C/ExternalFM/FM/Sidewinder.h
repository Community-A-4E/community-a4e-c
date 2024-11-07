#pragma once
#include "Interface.h"

class Sidewinder
{
public:
	Sidewinder( Scooter::ParameterInterface& inter ) : m_interface( inter ) {}

	void init();
	void update();

private:
	void* m_weaponSystem = nullptr;
	void* m_seeker = nullptr;
	Scooter::ParameterInterface& m_interface;
};

void Sidewinder::init()
{
	if ( m_weaponSystem && m_seeker )
		return;

	m_weaponSystem = m_interface.getWeapPointer();

	if ( ! m_weaponSystem )
		return;

	m_seeker = *((void**)((intptr_t)m_weaponSystem + 0x158));
	printf( "Seeker %p\n", m_seeker );
}

void Sidewinder::update()
{
	if ( m_seeker )
	{
		m_interface.api().pfn_set_radius( m_seeker, 28000.0 );
	}
		
}
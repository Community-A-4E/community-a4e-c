#pragma once
#include <Common/Maths.h>
#include "Interface.h"
#include "Input.h"
#include <vector>

static inline void wrapPoint( Vec3& p )
{
	if ( p.x > 1.0 )
		p.x -= 2.0;
	else if ( p.x < -1.0 )
		p.x += 2.0;

	if ( p.z > 1.0 )
		p.z -= 2.0;
	else if ( p.z < -1.0 )
		p.z += 2.0;
}

static Vec3 randomVector()
{
	double dir = random() * PI * 2;
	Vec3 result( cos( dir ), 0.0, sin( dir ) );
	return result;
}

class Asteroid
{
public:

	void set( const Vec3& pos, const Vec3& vel, double size )
	{
		m_position = pos;
		m_velocity = vel;
		m_size = size;
		m_alive = true;
	}

	void setInterface( Scooter::ParameterInterface* inter )
	{
		m_interface = inter;
	}

	void setParams( int min )
	{
		char paramName[50];
		for ( size_t i = 0; i < 10; i++ )
		{
			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_LR", i + min );
			m_pointsX[i] = m_interface->api().pfn_ed_cockpit_get_parameter_handle( paramName );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_UD", i + min );
			m_pointsY[i] = m_interface->api().pfn_ed_cockpit_get_parameter_handle( paramName );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_OP", i + min );
			m_pointsO[i] = m_interface->api().pfn_ed_cockpit_get_parameter_handle( paramName );
		}
	}

	void update( double dt )
	{
		if ( ! m_alive )
			return;

		m_position += m_velocity * dt;
		wrapPoint( m_position );
	}

	bool isAlive()
	{
		return m_alive;
	}

	void draw()
	{
		if ( m_alive )
		{
			for ( size_t i = 0; i < 10; i++ )
			{
				Vec3 position;
				position.x = m_size * cos( 2.0 * PI * (double)i / 10.0 ) + m_position.x;
				position.z = m_size * sin( 2.0 * PI * (double)i / 10.0 ) + m_position.z;

				wrapPoint( position );

				m_interface->setParamNumber( m_pointsX[i], position.x );
				m_interface->setParamNumber( m_pointsY[i], position.z );
				m_interface->setParamNumber( m_pointsO[i], 1.0 );
			}
		}
		else
		{
			for ( size_t i = 0; i < 10; i++ )
			{
				m_interface->setParamNumber( m_pointsO[i], 0.0 );
			}
		}
	}

	const Vec3& position()
	{
		return m_position;
	}

	const Vec3& velocity()
	{
		return m_velocity;
	}

	const double size()
	{
		return m_size;
	}

	void kill()
	{
		m_alive = false;
	}

private:
	void* m_pointsX[10];
	void* m_pointsY[10];
	void* m_pointsO[10];
	double m_size = 0.3;
	double m_alive = false;
	Vec3 m_position;
	Vec3 m_velocity;
	Scooter::ParameterInterface* m_interface;
};

class Bullet
{
public:
	void setInterface( Scooter::ParameterInterface* inter )
	{
		m_interface = inter;
	}

	void setParams( void* x, void* y, void* o )
	{
		m_x = x;
		m_y = y;
		m_o = o;
	}

	void set( const Vec3& pos, const Vec3& vel )
	{
		m_position = pos;
		m_velocity = vel;
		m_time = 3.0;
	}

	void update(double dt)
	{
		if ( ! alive() )
			return;

		m_position += m_velocity * dt;

		wrapPoint( m_position );

		m_time -= dt;
	}

	const Vec3& position()
	{
		return m_position;
	}

	void draw()
	{
		if ( m_time > 0.0 )
		{
			m_interface->setParamNumber( m_x, m_position.x );
			m_interface->setParamNumber( m_y, m_position.z );
			m_interface->setParamNumber( m_o, 1.0 );
		}
		else
			m_interface->setParamNumber( m_o, 0.0 );
	}

	void kill()
	{
		m_time = 0;
	}

	bool alive()
	{
		return m_time > 0;
	}

private:
	Vec3 m_velocity;
	Vec3 m_position;
	double m_time;
	Scooter::ParameterInterface* m_interface;
	void* m_x;
	void* m_y;
	void* m_o;
};

class SpaceShip
{
public:

	SpaceShip(Scooter::ParameterInterface* inter):
		m_interface(inter)
	{
		char paramName[50];

		for ( size_t i = 0; i < 6; i++ )
		{
			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_LR", i );
			m_pointsX[i] = m_interface->api().pfn_ed_cockpit_get_parameter_handle( paramName );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_UD", i );
			m_pointsY[i] = m_interface->api().pfn_ed_cockpit_get_parameter_handle( paramName );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_OP", i );
			m_pointsO[i] = m_interface->api().pfn_ed_cockpit_get_parameter_handle( paramName );
		}
	}

	void reset()
	{
		m_dir = 0;
		m_position = Vec3();
		m_velocity = Vec3();
		m_fireTime = 0;
	}

	const Vec3& position()
	{
		return m_position;
	}

	void turn( double v )
	{
		m_dirVel = v * 4.0; 
	}

	double size()
	{
		return m_size;
	}

	void update( double dt )
	{
		m_dir += m_dirVel * dt;
		m_dir = fmod( m_dir, 2.0 * PI );

		Vec3 acceleration = Scooter::directionVector( 0.0, m_dir ) * m_force;
		m_velocity += acceleration * dt;
		m_position += m_velocity * dt;

		m_fireTime -= dt;
		if ( m_fireTime < 0 )
			m_fireTime = 0;
	}

	void draw()
	{
		Vec3 fwd = Scooter::directionVector( 0.0, m_dir );
		Vec3 right = Scooter::directionVector( 0.0, m_dir + (PI / 2.0) );
		m_points[0] = fwd * m_size + m_position;
		m_points[1] = -fwd * m_size + right * m_size + m_position;
		m_points[2] = -fwd * m_size - right * m_size + m_position;
		m_points[3] = right * m_size * 0.5 + m_position;
		m_points[4] = -right * m_size * 0.5 + m_position;
		m_points[5] = -fwd * m_size * 2 + m_position;

		wrapPoint( m_position );

		for ( size_t i = 0; i < 6; i++ )
		{
			wrapPoint( m_points[i] );

			m_interface->setParamNumber( m_pointsX[i], m_points[i].x );
			m_interface->setParamNumber( m_pointsY[i], m_points[i].z );

			if ( i != 5 || m_force > 0.0 )
				m_interface->setParamNumber( m_pointsO[i], 1.0 );
			else
				m_interface->setParamNumber( m_pointsO[i], 0.0 );
		}
	}

	void engine( bool on )
	{
		m_force = 0.5 * (double)on;
	}

	bool fire(Vec3& pos, Vec3& vel)
	{
		if ( m_fireTime > 0.0 )
			return false;

		pos = m_position;
		vel = 1.5 * Scooter::directionVector( 0.0, m_dir ) + m_velocity;
		m_fireTime = 0.5;
		return true;
	}

private:
	double m_force = 0.0;
	const double m_size = 0.07;
	double m_dir = 0.0;
	double m_dirVel = 0.0;
	Vec3 m_position;
	Vec3 m_velocity;
	Vec3 m_points[6];
	void* m_pointsX[6];
	void* m_pointsY[6];
	void* m_pointsO[6];
	Scooter::ParameterInterface* m_interface;
	double m_fireTime = 0;
};

class Asteroids
{
public:
	Asteroids( Scooter::ParameterInterface* inter ) :
		m_ship( inter ),
		m_interface(inter)
	{
		char paramName[50];
		for ( size_t i = 0; i < numBullets; i++ )
		{
			m_bullets[i].setInterface( inter );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_LR", i + 6 );
			void* x = inter->api().pfn_ed_cockpit_get_parameter_handle( paramName );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_UD", i + 6 );
			void* y = inter->api().pfn_ed_cockpit_get_parameter_handle( paramName );

			sprintf_s( paramName, 50, "RADAR_BLOB_%llu_OP", i + 6 );
			void* o = inter->api().pfn_ed_cockpit_get_parameter_handle( paramName );
			m_bullets[i].setParams( x, y, o );
		}

		for ( int i = 0; i < numAsteroids; i++ )
		{
			m_asteroids[i].setInterface( inter );
			m_asteroids[i].setParams( ( numBullets + 7 ) + i * 20 );
		}

		reset();
	}

	void reset()
	{
		m_spawnTimer = 0;
		m_ship.reset();

		if ( m_score > m_highScore )
		{
			m_highScore = m_score;
			LOG( "Asteroids new high score: %d\n", m_score );
		}

		m_score = 0;

		for ( size_t i = 0; i < numBullets; i++ )
		{
			m_bullets[i].kill();
		}

		for ( size_t i = 0; i < numAsteroids; i++ )
		{
			m_asteroids[i].kill();
		}
	}

	void addAsteroid( const Vec3& pos, const Vec3& vel, double size )
	{
		for ( size_t i = 0; i < numAsteroids; i++ )
		{
			if ( ! m_asteroids[i].isAlive() )
			{
				m_asteroids[i].set( pos, vel, size );
				return;
			}
		}
	}

	void splitAsteroid( Asteroid& asteroid )
	{
		Vec3 perp = cross( asteroid.velocity(), Vec3( 0.0, 1.0, 0.0 ) ) * 0.4;
		double newSize = asteroid.size() / 2.0;

		m_score += (int)( 0.2 / asteroid.size() );

		if ( newSize < 0.05 )
		{
			asteroid.kill();
			return;
		}

		Vec3 pos = asteroid.position();
		Vec3 vel = asteroid.velocity();

		asteroid.set( pos, vel + perp, newSize );
		addAsteroid( pos, vel, newSize );
	}

	void update( double dt )
	{
		m_ship.update( dt );

		for ( size_t i = 0; i < numBullets; i++ )
		{
			m_bullets[i].update( dt );
		}

		m_spawnTimer -= dt;

		if ( m_spawnTimer <= 0.0 )
		{
			addAsteroid( randomVector(), randomVector() * 0.5, 0.2 );
			m_spawnTimer = std::min(( 20.0 / ( ( (double)m_score + 1.0 ) / 30.0 ) ), 20.0);
			printf( "Time until next asteroid: %lf\n", m_spawnTimer );
		}

		for ( size_t i = 0; i < numAsteroids; i++ )
		{
			m_asteroids[i].update( dt );

			if ( m_asteroids[i].isAlive() )
			{
				for ( size_t j = 0; j < numBullets; j++ )
				{
					Vec3 playerDelta = m_ship.position() - m_asteroids[i].position();
					if ( magnitude( playerDelta ) < (m_asteroids[i].size()+ m_ship.size()) )
					{
						reset();
					}


					if ( m_bullets[j].alive() )
					{
						Vec3 delta = m_bullets[j].position() - m_asteroids[i].position();
						double distance = magnitude( delta );
						if ( distance < m_asteroids[i].size() )
						{
							splitAsteroid( m_asteroids[i] );
							m_bullets[j].kill();
						}
					}
				}
			}
		}

		if ( m_fireOn )
		{
			Vec3 pos;
			Vec3 vel;
			if ( m_ship.fire( pos, vel ) )
			{
				m_bullets[m_bulletIndex].set( pos, vel );
				m_bulletIndex = ( m_bulletIndex + 1 ) % numBullets;
			}
		}
	}

	void draw()
	{
		m_interface->eggScore( m_score );
		m_interface->eggHighScore( m_highScore );
		m_ship.draw();

		for ( size_t i = 0; i < numBullets; i++ )
		{
			m_bullets[i].draw();
		}

		for ( size_t i = 0; i < numAsteroids; i++ )
		{
			m_asteroids[i].draw();
		}
	}

	inline void turn( double v )
	{
		m_ship.turn( v );
	}

	inline void engine( bool v )
	{
		m_ship.engine( v );
	}

	inline void fire(bool on)
	{
		m_fireOn = on;
	}

private:
	SpaceShip m_ship;

	static constexpr int numBullets = 10;
	static constexpr int numAsteroids = 20;
	Bullet m_bullets[numBullets];
	Asteroid m_asteroids[numAsteroids];
	int m_bulletIndex = 0;
	double m_spawnTimer = 0.0;
	int m_score = 0;
	int m_highScore = 0;
	bool m_fireOn = false;
	Scooter::ParameterInterface* m_interface;
};

static inline void egg( double dt, Asteroids* asteroids, Scooter::Input& input )
{
	asteroids->update( dt );
	asteroids->draw();
	asteroids->turn( input.rollAxis().getValue() );
	asteroids->engine( input.pitchAxis().getValue() > 0.1 );
}
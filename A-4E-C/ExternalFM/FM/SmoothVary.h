#pragma once
#include <Common/Maths.h>
class SmoothVary
{
public:
	SmoothVary() 
	{
		calculateTotal();
	}
	SmoothVary( double value, double freq ) :
		m_value( value ),
		m_freq(freq)
	{
		calculateTotal();
	}

	void calculateTotal()
	{
		m_total = 0.0;

		for ( size_t i = 0; i < size; i++ )
		{
			m_total += m_scales[i];
		}
	}

	double update( double dt )
	{
		m_time += dt;
		
		m_value = 0.0;

		for ( size_t i = 0; i < size; i++ )
		{
			m_value += m_scales[i] * sin( m_freq * m_constants[i] * m_freqs[i] * m_time );
		}

		m_value /= m_total;

		if ( m_time > m_period && abs( m_value ) < 0.001 )
			m_time = 0.0;

		return m_value * m_scale;
	}

	inline void setScale( double scale )
	{
		m_scale = scale;
	}

private:

	static constexpr size_t size = 4;
	const double m_scales[size] = {0.3, 0.2, 0.35, 0.25};
	const double m_freqs[size] = {0.3, 0.2, 0.35, 0.25};
	const double m_constants[size] = { sqrt( 2.0 ), sqrt( 17.0 ), 1.0, 1.0 };
	double m_total = 1.0;
	double m_time = 0.0;
	double m_scale = 1.0;
	double m_freq = 1.0;

	double m_value = 0.0;

	const double m_period = 100.0;
};
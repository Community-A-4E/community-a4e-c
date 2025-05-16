#pragma once
#ifndef TABLE_H
#define TABLE_H
//=========================================================================//
//
//		FILE NAME	: Table.h
//		AUTHOR		: Joshua Nelson
//		DATE		: May 2020
//
//		This file falls under the licence found in the root ExternalFM directory.
//
//		DESCRIPTION	:	The two table classes here provide an interface to easily
//						access values from a 1 dimensional data table. Values must
//						be evenly spaced, this is to reduce storage requirements
//						and accessing complexity.
//
//================================ Includes ===============================//
#include <vector>
//=========================================================================//

class Table
{
public:
	Table(const std::vector<double>& table, double min, double max) :
		m_table(table),
		m_min(min),
		m_max(max)
	{
		m_dx = (max - min) / ((double)table.size()-1);
		m_minIndex = int(min / m_dx);
	}

	double operator()(double value)
	{

		if (m_table.size() == 1)
			return m_table[0];

		double index = (value - m_min) / m_dx;

		int lower = int(floor(index));
		int upper = int(ceil(index));

		if (lower == upper)
			upper++;

		if (lower < 0)
			return m_table.front();
		if (upper >= m_table.size())
			return m_table.back();

		double lowerX = (double)lower * m_dx + m_min;
		double upperX = (double)upper * m_dx + m_min;

		return (value - lowerX) * ((m_table[upper] - m_table[lower]) / (upperX - lowerX)) + m_table[lower];
	}

private:
	const std::vector<double> m_table;
	double m_dx;
	double m_min;
	double m_max;
	int m_minIndex;
};

class ZeroTable
{
public:
	ZeroTable( const std::vector<double>& table, double min, double max ) :
		m_table( table ),
		m_min( min ),
		m_max( max )
	{
		m_dx = (max - min) / ((double)table.size() - 1);
		m_minIndex = int(min / m_dx);
	}

	double operator()( double value )
	{

		if ( m_table.size() == 1 )
			return m_table[0];

		double index = (value - m_min) / m_dx;

		int lower = int(floor( index ));
		int upper = int(ceil( index ));

		if ( lower == upper )
			upper++;

		if ( lower < 0 )
		{
			return (value - m_min) * (m_table.front() / m_min) + m_table.front();
		}
		if ( upper >= m_table.size() )
			return m_table.back();

		double lowerX = (double)lower * m_dx + m_min;
		double upperX = (double)upper * m_dx + m_min;

		return (value - lowerX) * ((m_table[upper] - m_table[lower]) / (upperX - lowerX)) + m_table[lower];
	}

private:
	const std::vector<double> m_table;
	double m_dx;
	double m_min;
	double m_max;
	int m_minIndex;
};



#endif

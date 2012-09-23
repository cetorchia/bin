#!/usr/bin/perl -w
#
# Use the nutrient database to get nutrition information
# (c) 2010 Carlos E. Torchia
#

use strict;
use lib '/home/carlos/src';
use DB;

my $dbDir = '/home/carlos/cnf';
my $nutrientTable = $dbDir . '/NT_NM.txt';
my $foodTable = $dbDir . '/FOOD_NM.txt';
my $nutrientAmountsTable = $dbDir . '/NT_AMT.txt';
my $conversionsTable = $dbDir . '/CONV_FAC.txt';
my $measureTable = $dbDir . '/MEASURE.txt';

#
# Process command line
#

if(scalar(@ARGV) < 1)
{
	print STDERR "Usage: nutrition <food> [nutrient]\n";
	exit 1;
}

my $food = shift;
my $nutrient = shift;

#
# Get nutrient and food records into memory
#

my @foods = @{DB::get($foodTable, { 'L_FD_NME' => $food})};
my @nutrients;
my @measures;
my @nutrientAmounts;

if(defined $nutrient)
{
	@nutrients = @{DB::get($nutrientTable, { 'NT_NME' => $nutrient})};
	@measures = @{DB::get($measureTable, {})};
	@nutrientAmounts = @{DB::get($nutrientAmountsTable, {})};
}

#
# Query the data for each food
#

foreach my $foodRow (@foods)
{
	my $foodName = $foodRow->{'L_FD_NME'};
	my $foodId = $foodRow->{'FD_ID'};

	print "Food " . $foodName . "\n";

	if(!defined $nutrient)
	{
		next;
	}

	#
	# Display the conversion factors
	#

	my @conversions = @{DB::get($conversionsTable, { 'FD_ID' => $foodId})};
	foreach my $conversion (@conversions)
	{
		my $measureId = $conversion->{'MSR_ID'};
		my $factor = $conversion->{'CONV_FAC'};

		foreach my $measure (@measures)
		{
			if($measure->{'MSR_ID'} eq $measureId)
			{
				my $measureName = $measure->{'MSR_NME'};

				print "\tMeasure " .
					$measureName . " " .
					$factor . "\n";
			}
		}
	}

	#
	# Display each nutrient and the amount in the food.
	#

	foreach my $nutrientRow (@nutrients)
	{
		my $nutrientId = $nutrientRow->{'NT_ID'};
		my $nutrientName = $nutrientRow->{'NT_NME'};
		my $nutrientUnit = $nutrientRow->{'UNIT'};

		foreach my $nutrientAmount (@nutrientAmounts)
		{
			if(($nutrientAmount->{'FD_ID'} eq $foodId) and
			   ($nutrientAmount->{'NT_ID'} eq $nutrientId))
			{
				my $value = $nutrientAmount->{'NT_VALUE'};

				print "\tNutrient " .
					$nutrientName . " " .
					$value . " " .
					$nutrientUnit . "\n";
			}
		}
	}
}

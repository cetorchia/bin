#!/usr/bin/perl -w
#
# Load the nutrition database into MySQL tables.
# (c) 2010 Carlos E. Torchia
#

use strict;
use lib '/home/carlos/src';
use DB;

die("Usage: cnf.pl <table>\n") if scalar(@ARGV) != 1;
my $table = $ARGV[0];
my $filename = '/home/carlos/cnf/' . $table . '.txt';

print "USE nutrition87;\n";

#
# Get nutrient and food records into memory
#

my @rows = @{DB::get($filename, {})};

#
# Get the column names, make the table
#

my %row = %{$rows[1]};
my @columns = ();
my @columnDefs = ();
my %columnTypes = ();
foreach my $x (keys %row)
{
	my $y = $row{$x};
	my $type = "DOUBLE";
	$type = "TEXT" if($y =~ /^".*"$/);
	$type = "INTEGER" if ($x =~ /(_ID|_CODE|_C|_COD)$/);

	$columnTypes{$x} = $type;
	push @columns, $x;
	push @columnDefs, "$x $type";
}

$" = ', ';

my $columnClause = "(@columnDefs)";
print "CREATE TABLE IF NOT EXISTS $table $columnClause;\n";

#
# Insert each row into the database
#

$columnClause = "(@columns)";
foreach my $row (@rows)
{
	my @values = ();
	foreach my $column (@columns)
	{
		my $value = $row->{$column};
		$value =~ s/'/\\'/g;
		$value =~ s/^"(.*)"$/'$1'/;
		$value = "NULL" if($value eq '');

		push @values, $value;
	}

	my $valueClause = "(@values)";
	print "INSERT INTO $table $columnClause VALUES $valueClause;\n";
}

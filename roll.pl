#!/usr/bin/perl -w
use strict;

# D&D rolling script (custom random number generator)
#
# for example: '2d10' will roll two d-10's and output their values, plus a sum,
# '3x4d6' will roll four d-6's in three separate throws and output all values,
# plus a sum for each throw, plus a total sum

use constant DEBUG	=> 0;

use Getopt::Std	qw/ getopts /;

my %opts = (
	'o'	=> 0, # order dice output?
);

&getopts('o', \%opts);

foreach my $throw_type (@ARGV) {

	# trim flash (enables calling with 'd[num]' for a single die)
	$throw_type =~ s/(^\D+|\D+$)//g;

	# interpret throw type backwards (golf)
	my ($sides, $dice, $throws) = reverse split /\D/, $throw_type;

	$throws = 1 unless defined $throws;
	$dice = 1 unless defined $dice;

	print STDERR "throws: $throws, dice: $dice, sides: $sides\n"
		if DEBUG;
	# determine how many places to format the dice values to
	my $value_format = '%' . length (int $sides) . 'd';

	foreach my $throw_number (1 .. $throws) {
		print "throw ${throw_number}: " if $throws > 1;
		my $throw_sum = 0;
		my @dice_totals;
		foreach my $die_number (1 .. $dice) {
			my $die_value = 1 + int rand $sides;
			$throw_sum += $die_value;
			push @dice_totals, $die_value;
		}
		print ' [', join (']  [',
			map {
				sprintf $value_format, $_
			} ($opts{'o'} ?
				sort {$a <=> $b} @dice_totals :
				@dice_totals)
			), "]  = $throw_sum\n";
	}

}

#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

# D&D rolling script (custom random number generator)
#
# for example: '2d10' will roll two d-10's and output their values, plus a sum,
# '3x4d6' will roll four d-6's in three separate throws and output all values,
# plus a sum for each throw, plus a total sum
#
# Script first conceived 2009-08-26

use Getopt::Long qw/ GetOptions /;
Getopt::Long::Configure('no_ignore_case');
# (this prepends to the load path) :squash-ignore-line:
use File::Basename  qw/ dirname /; # :squash-ignore-line:
use Cwd             qw/ realpath /; # :squash-ignore-line:
use lib &dirname(&realpath($0)); # :squash-ignore-line:
require Dice::Roll;
require Dice::Roll::Die;

MAIN: {
    my $throws = 1;
    my (
        $discard_low,
        $discard_high,
        $print_total,
    );

    &GetOptions(
        'discard-low=i' => \$discard_low,
        'discard-high=i' => \$discard_high,
        'throws=i' => \$throws,
        'total' => \$print_total, 'sum' => \$print_total,
        'no-total' => sub { $print_total = 0 }, 'no-sum' => sub { $print_total = 0 },
    ) || exit 2;

    my @rolls;
    foreach my $throw_type (@ARGV) {
        for (my $throw_num = 0; $throw_num < $throws; ++$throw_num) {
            my $roll = Dice::Roll->new(
                $throw_type,
            );

            # Perform discards
            my @dice = $roll->dice_sorted;
            if (defined $discard_low) {
                for (my $i = 0; $i < $discard_low; ++$i) {
                    if (defined $dice[$i]) {
                        $dice[$i]->discard;
                    }
                }
            }
            if (defined $discard_high) {
                @dice = reverse @dice;
                for (my $i = 0; $i < $discard_high; ++$i) {
                    if (defined $dice[$i]) {
                        $dice[$i]->discard;
                    }
                }
            }

            print "$roll\n";
            push @rolls, $roll;
        }
    }

    # Print summation
    if (!defined $print_total && @rolls > 1
        || $print_total
    ) {
        use List::Util qw/ sum /;
        printf "Total: %d\n", &sum(0, @rolls);
    }
}

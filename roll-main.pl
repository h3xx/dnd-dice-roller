#!/usr/bin/perl
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;

=head1 NAME

roll.pl - Dungeons & Dragons (D&D) dice roller

=head1 SYNOPSIS

B<roll.pl> [I<OPTION>]... [I<DICE>]...

=head1 OPTIONS

DICE can take different forms. The general form is \d*(d\d+)? (example: C<4d8> or C<d20>). DICE can also be a numeric constant.

A C<+> character can be used to concatenate dice types (example: C<2d6+d8+2> will roll d6, d6, d8, and add 2)

=over 4

=item --char-5e

Sets options for rolling a D&D 5th Edition character's ability scores. Equivalent to C<--discard-low=1 --discard-high=0 --no-total --throws=6 4d6>.

=item --discard-low=I<NUM>, --discard-high=I<NUM>

Discard the lowest or highest NUM dice from each throw.

=item --throws=I<NUM>

Roll all dice NUM times.

=item --total, --no-total

Turn on or off display of a total. By default no total is shown if there's only one roll.

=item --help

Display this help and exit.

=back

=head1 COPYRIGHT

Copyright (C) 2009-2021 Dan Church S<E<lt>amphetamachine@gmail.comE<gt>>.
License GPLv3+: GNU GPL version 3 or later (L<http://gnu.org/licenses/gpl.html>).
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

=cut

# D&D rolling script (custom random number generator)
#
# for example: '2d10' will roll two d-10's and output their values, plus a sum,
# '3x4d6' will roll four d-6's in three separate throws and output all values,
# plus a sum for each throw, plus a total sum
#
# Script first conceived 2009-08-26

use Getopt::Long qw/ GetOptions /;
use Pod::Usage qw/ pod2usage /;

# :squash-ignore-start:
# (this prepends to the load path)
use File::Basename  qw/ dirname /;
use Cwd             qw/ realpath /;
use lib &dirname(&realpath($0));
# :squash-ignore-end:

require Dice::Roll;
require Dice::Roll::Die;

MAIN: {
    my $throws = 1;
    my (
        $discard_low,
        $discard_high,
        $help,
        $print_total,
        @throw_types,
    );

    # Roll recipe for rolling up stats for a 5e character sheet
    my $_recipe_5e_character = sub {
        $discard_low = 1;
        $discard_high = 0;
        $print_total = 0;
        @throw_types = qw/ 4d6 /;
        $throws = 6;
    };

    Getopt::Long::Configure('no_ignore_case');
    &GetOptions(
        'char-5e' => $_recipe_5e_character,
        'discard-low=i' => \$discard_low,
        'discard-high=i' => \$discard_high,
        'help' => \$help,
        'throws=i' => \$throws,
        'total' => \$print_total, 'sum' => \$print_total,
        'no-total' => sub { $print_total = 0 }, 'no-sum' => sub { $print_total = 0 },
    ) || &pod2usage(
        -exitval => 2,
        -msg => "Try 'roll.pl --help' for more information",
    );

    &pod2usage(
        -verbose => 1,
        -exitval => 0,
    ) if $help;

    @throw_types = @ARGV unless @throw_types;

    my @rolls;
    foreach my $throw_type (@throw_types) {
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

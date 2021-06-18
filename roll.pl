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

MAIN: {
    my $throws = 1;
    my (
        $discard_low,
        $discard_high,
    );

    &GetOptions(
        'discard-low=i' => \$discard_low,
        'discard-high=i' => \$discard_high,
        'throws=i' => \$throws,
    ) || exit 2;

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
        }
    }
}

package Dice::Roll;
use strict;
use warnings;
use overload '""' => 'as_string';
use overload '0+' => 'total';

sub new {
    my $class = shift;
    my $throw_type = shift;

    my @dice;
    foreach my $die_type (split /\+/, $throw_type) {
        my $mult = 1;
        if ($die_type =~ /^(\d+)([Dd].+)$/) {
            $mult = $1;
            $die_type = $2;
        }
        while ($mult-- > 0) {
            push @dice, Dice::Roll::Die->new($die_type);
        }
    }

    bless {
        dice => \@dice,
        @_,
    }, $class
}

sub dice {
    my $self = shift;
    @{$self->{dice}}
}

sub dice_sorted {
    my $self = shift;
    sort { $a->val <=> $b->val } $self->dice
}

sub total {
    my $self = shift;
    use List::Util qw/ sum /;
    &sum(map { $_->val } $self->dice)
}

sub as_string {
    my $self = shift;
    sprintf ' %s  = %d',
        (join '  ', $self->dice),
        $self->total
}

package Dice::Roll::Die;
use strict;
use warnings;
use overload '""' => 'as_string';
use overload '0+' => 'val';

use Term::ANSIColor qw/ colored /;

sub new {
    my $class = shift;
    my $die_type = shift;
    my ($sides, $val, $face);
    my $frozen = 0;
    if ($die_type =~ /(\d+)$/) {
        my $sides_or_val = $1;

        if ($die_type =~ /^[Dd]/) {
            $sides = $sides_or_val;
        } else {
            # Single constant number
            $val = $face = $sides_or_val;
            $frozen = 1;
        }
    } else {
        die "Unrecognized die type: $die_type";
    }
    bless {
        sides => $sides,
        val => $val,
        frozen => $frozen,
        face => $face,
        @_,
    }, $class
}

sub freeze {
    shift->{frozen} = 1;
}

sub roll {
    my $self = shift;
    if (defined $self->{sides} && $self->{sides} > 0) {
         return 1 + int rand $self->{sides};
    }
    die 'Unable to choose die value due to invalid number of sides';
}

sub face {
    my $self = shift;
    if (! defined $self->{face} || ! $self->{frozen}) {
        $self->{face} = $self->roll;
        $self->freeze;
    }
    $self->{face}
}

sub val {
    my $self = shift;
    if ($self->{discarded}) {
        return 0;
    } else {
        return $self->face;
    }
}

sub discard {
    my $self = shift;
    $self->{color} = 'bright_black';
    $self->{discarded} = 1;
}

sub as_string {
    my $self = shift;

    my $pat;
    if ($self->{sides}) {
        # $pat = '[%' . length (int $self->{sides}) . 'd]';
        $pat = '[%d]';
    } else {
        $pat = ' %d ';
    }
    if ($self->{color}) {
        $pat = &colored($pat, $self->{color});
    }
    sprintf $pat, $self->face;
}

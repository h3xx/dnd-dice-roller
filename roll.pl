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

#use constant DEBUG => 1;

use Getopt::Std qw/ getopts /;

MAIN: {
    my %opts = (
        o   => 0, # order dice output?
    );

    &getopts('o', \%opts);

    foreach my $throw_type (@ARGV) {
        print Dice::Roll->new(
            $throw_type,
            ordered => $opts{o},
        ), "\n";
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
    if ($self->{ordered}) {
        sort { $a->val <=> $b->val } @{$self->{dice}}
    } else {
        @{$self->{dice}}
    }
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

sub new {
    my $class = shift;
    my $die_type = shift;
    my ($sides, $val);
    my $frozen = 0;
    if ($die_type =~ /(\d+)$/) {
        my $sides_or_val = $1;

        if ($die_type =~ /^[Dd]/) {
            $sides = $sides_or_val;
        } else {
            $val = $sides_or_val;
            $frozen = 1;
        }
    } else {
        die "Unrecognized die type: $die_type";
    }
    bless {
        sides => $sides,
        val => $val,
        frozen => $frozen,
        @_,
    }, $class
}

sub freeze {
    shift->{frozen} = 1;
}

sub roll {
    my $self = shift;
    my $val;
    if (defined $self->{sides} && $self->{sides} > 0) {
         return 1 + int rand $self->{sides};
    }
    die 'Unable to choose die value due to invalid number of sides';
}

sub val {
    my $self = shift;
    if (! defined $self->{val} || ! $self->{frozen}) {
        $self->{val} = $self->roll;
        $self->freeze;
    }
    $self->{val}
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
    sprintf $pat, $self->val;
}

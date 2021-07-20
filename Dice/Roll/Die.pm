package Dice::Roll::Die;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use overload
    '0+' => 'val',
    '""' => 'as_string',
    fallback => 1,
    ;

use Term::ANSIColor qw/ colored /;

sub new {
    my ($class, $die_type) = @_;
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

1;

=head1 AUTHOR

Dan Church S<E<lt>h3xx@gmx.comE<gt>>

=head1 COPYRIGHT

Copyright (C) 2021 Dan Church.

License GPLv3+: GNU GPL version 3 or later (http://gnu.org/licenses/gpl.html).
This is free software: you are free to change and redistribute it. There is NO
WARRANTY, to the extent permitted by law.

=cut

package Dice::Roll;
# vi: et sts=4 sw=4 ts=4
use strict;
use warnings;
use overload
    '""' => 'as_string',
    '0+' => 'total',
    fallback => 1,
    ;

require Dice::Roll::Die;

sub new {
    my ($class, $throw_type) = @_;

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
    &sum($self->dice)
}

sub as_string {
    my $self = shift;
    sprintf ' %s  = %d',
        (join '  ', $self->dice),
        $self->total
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

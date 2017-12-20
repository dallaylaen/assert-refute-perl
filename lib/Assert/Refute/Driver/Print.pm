package Assert::Refute::Driver::Print;

use strict;
use warnings;
our $VERSION = 0.0401;

=head1 NAME

Assert::Refute::Driver::Print - tap producer module for Assert::Refute suite

=cut

use parent qw(Assert::Refute::Exec);

=head2 new

=cut

sub new {
    my ($class, %opt) = @_;

    my $self = $class->SUPER::new( %opt );
    $self->{handle} ||= \*STDOUT;
    return $self;
};

=head2 do_log

=cut

sub do_log {
    my ($self, $indent, $level, $msg) = @_;
    $self->SUPER::do_log( $indent, $level, $msg );

    my $padding = ('    'x$indent) . ($level > 0 ? ('#' x $level ." ") : "");
    print {$self->{handle}} "$padding$_\n"
        for grep { length $_ } split /\n/, join '', $msg;
    return $self;
};

1;

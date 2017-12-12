package Assert::Refute::Contract;

use 5.006;
use strict;
use warnings;
our $VERSION = 0.0106;

=head1 NAME

Assert::Refute::Contract - Contract specification class for Assert::Refute

=head1 SYNOPSIS

    use Assert::Refute::Contract;

    my $contract = Assert::Refute::Contract->new(
        code => sub {
            my ($c, $life) = @_;
            $c->is( $life, 42 );
        },
        want_self => 1,
    );

    # much later
    my $result = $contract->execute( 137 );
    $result->count;      # 1
    $result->is_passing; # 0
    $result->as_tap;     # Test::More-like summary

=head1 DESCRIPTION

This is a contract B<specification> class.
See L<Assert::Refute::Exec> for execution log.
See L<Assert::Refute/contract> for convenient interface.

=cut

use Carp;

use Assert::Refute::Exec;

our $ENGINE;

=head1 OBJECT-ORIENTED INTERFACE

=head2 new

    Assert::Refute::Contract->new( %options );

%options may include:

=over

=item * C<code> (required) - contract to be executed

=back

=cut

my %new_arg;
$new_arg{$_}++ for qw(code want_self);

sub new {
    my ($class, %opt) = @_;

    UNIVERSAL::isa($opt{code}, 'CODE')
        or croak "code argument is required";
    my @extra = grep { !$new_arg{$_} } keys %opt;
    croak "Unknown options: @extra"
        if @extra;

    bless {
        code      => $opt{code},
        engine    => 'Assert::Refute::Exec',
        want_self => $opt{want_self} ? 1 : 0,
    }, $class;
};

=head2 exec

Spawn a new execution log object and run contract against it.

=cut

sub exec {
    my ($self, @args) = @_;

    my $c = $self->{engine}->new;
    # TODO plan argcheck etc

    unshift @args, $c if $self->{want_self};
    local $ENGINE = $c;
    eval {
        $self->{code}->( @args );
        $c->done_testing
            unless $c->is_done;
        1;
    } || do {
        $c->done_testing($@ || "Unexpected end of tests");
    };

    # At this point, done_testing *has* been called unless of course
    #    it is broken and dies, in which case tests will fail.
    return $c;
};

=head2 current_contract

Returns the contract object being executed.
Dies if no contract is being executed at the time.

=cut

sub current_contract() { ## nocritic
    croak "Not currently testing anything"
        unless $ENGINE;
    return $ENGINE;
};

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

This module is part of L<Assert::Refute> suite.

Copyright 2017 Konstantin S. Uvarin. C<< <khedin at gmail.com> >>

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

1; # End of Assert::Refute

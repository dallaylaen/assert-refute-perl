package Assert::Refute::Exec;

use 5.006;
use strict;
use warnings;
our $VERSION = 0.0501;

=head1 NAME

Assert::Refute::Exec - Contract execution class for Assert::Refute suite

=head1 DESCRIPTION

This class represents one specific application of contract.
It is mutable, but can only changed in one way
(there is no undo of tests and diagnostic messages).
Eventually a C<done_testing> locks it completely, leaving only
L</QUERYING PRIMITIVES> for inspection.

See L<Assert::Refute::Contract> for contract I<definition>.

=head1 SYNOPSIS

    my $c = Assert::Refute::Exec->new;
    $c->refute ( $cond, $message );
    $c->refute ( $cond2, $message2 );
    # .......
    $c->done_testing; # no more refute after this

    $c->get_count;    # how many tests were run
    $c->is_passing;   # did any of them fail?
    $c->get_tap;      # return printable summary in familiar format

=cut

use Carp;
use Scalar::Util qw(blessed);

use Assert::Refute::Build qw(to_scalar);

# Always add basic testing primitives to the arsenal
use Assert::Refute::T::Basic qw();

my $ERROR_DONE = "done_testing was called, no more changes may be added";

=head1 OBJECT-ORIENTED INTERFACE

=head2 new

    Assert::Refute::Exec->new( %options );

%options may include:

=over

=item * indent - log indentation (will be shown as 4 spaces in C<get_tap>);

=back

=cut

sub new {
    my ($class, %opt) = @_;

    bless {
        indent => $opt{indent} || 0,
        fail   => {},
        count  => 0,
    }, $class;
};

=head2 RUNNING PRIMITIVES

=head3 refute( $condition, $message )

An inverted assertion. That is, it B<passes> if C<$condition> is B<false>.

Returns inverse of first argument.
Dies if L</done_testing> was called.

See L<Assert::Refute/refute> for more detailed discussion.

=cut

sub refute {
    my ($self, $cond, $msg) = @_;

    $msg = $msg ? " - $msg" : '';
    my $n = ++$self->{count};

    if ($cond) {
        $self->set_result( $n, $cond );
        $self->do_log( 0, -1, "not ok $n$msg" );
        $self->do_log( 0,  1, $cond ) unless $cond eq 1;
        return 0;
    } else {
        $self->do_log( 0,  0, "ok $n$msg" );
        return 1;
    };
};

=head3 diag

    diag "Message", \%reference, ...;

Add human-readable diagnostic message to report.
References are explained to depth 1.

=head3 note

    diag "Message", \%reference, ...;

Add human-readable notice message to report.
References are explained to depth 1.

=cut

sub diag {
    my $self = shift;

    $self->do_log( 0, 1, join " ", map { to_scalar($_) } @_ );
};

sub note {
    my $self = shift;

    $self->do_log( 0, 2, join " ", map { to_scalar($_) } @_ );
};

=head3 done_testing

Stop testing.
After this call, no more writes (including done_testing)
can be performed on this contract.
This happens by default at the end of C<contract{ ... }> block.

Dies if called for a second time, I<unless> an argument is given.

A true argument is considered to be the exception
that interrupted the contract execution,
resulting in an unconditionally failed contract.

A false argument just avoids dying and is equivalent to

    $report->done_testing
        unless $report->is_done;

Returns self.

=cut

sub done_testing {
    my ($self, $exception) = @_;

    if ($exception) {
        delete $self->{done};
        $self->{has_error} = $exception;
        # Make sure there *is* a failing test on the outside
        $self->refute( $exception, "unexpected exception: $exception" );
        $self->do_log( 0, 1, "Looks like test execution was interrupted" );
    } elsif ($self->{done}) {
        return $self if defined $exception;
        $self->_croak( $ERROR_DONE );
    } else {
        $self->do_log(0, 0, "1..$self->{count}");
    };
    $self->do_log(0, 1,
        "Looks like $self->{fail_count} tests of $self->{count} have failed")
            if $self->{fail_count};

    $self->{done}++;
    return $self;
};

=head2 TESTING PRIMITIVES

L<Assert::Refute> comes with a set of basic checks
similar to that of L<Test::More>, all being wrappers around
L</refute> discussed above.
They are available as both prototyped functions (if requested) I<and>
methods in contract execution object and its descendants.

The list is as follows:

C<is>, C<isnt>, C<ok>, C<use_ok>, C<require_ok>, C<cmp_ok>,
C<like>, C<unlike>, C<can_ok>, C<isa_ok>, C<new_ok>,
C<contract_is>, C<is_deeply>, C<note>, C<diag>.

See L<Assert::Refute::T::Basic> for more details.

Additionally, I<any> checks defined using L<Assert::Refute::Build>
will be added to this L<Assert::Refute::Exec> by default.

=head3 subcontract( "Message" => $specification, @arguments ... )

Execute a previously defined contract and fail loudly if it fails.

B<[NOTE]> that the message comes first, unlike in C<refute> or other
test conditions, and is required.

=cut

sub subcontract {
    my ($self, $msg, $c, @args) = @_;

    $self->_croak("subcontract must be a contract definition or execution log")
        unless blessed $c;

    my $exec = $c->isa("Assert::Refute::Contract") ? $c->apply(@args) : $c;
    my $stop = !$exec->is_passing;
    $self->refute( $stop, "$msg (subtest)" );
    if ($stop) {
        my $log = $exec->get_log;
        $self->do_log( $_->[0]+1, $_->[1], $_->[2] )
            for @$log;
    };
};

=head2 QUERYING PRIMITIVES

=head3 is_done

Tells whether done_testing was seen.

=cut

sub is_done {
    my $self = shift;
    return $self->{done} || 0;
};


=head3 is_passing

Tell whether the contract is passing or not.

=cut

sub is_passing {
    my $self = shift;

    return !$self->{fail_count} && !$self->{has_error};
};

=head3 get_count

How many tests have been executed.

=cut

sub get_count {
    my $self = shift;
    return $self->{count};
};

=head3 get_fail_count

How many tests failed

=cut

sub get_fail_count {
    my $self = shift;
    return $self->{fail_count} || 0;
};

=head3 get_tests

Returns a list of test ids, preserving order.

=cut

sub get_tests {
    my $self = shift;
    return $self->{list} ? @{ $self->{list} } : ();
};

=head3 get_result( $id )

Returns result of test denoted by $id, dies if such test was never performed.
The result is false for passing tests and whatever the reason for failure was
for failing ones.

=cut

sub get_result {
    my ($self, $n) = @_;

    return $self->{fail}{$n} || 0
        if exists $self->{fail}{$n};

    return 0 if $n =~ /^[1-9]\d*$/ and $n<= $self->{count};

    $self->_croak( "Test $n has never been performed" );
};

=head3 get_error

Return last error that was recorded during contract execution,
or false if there was none.

=cut

sub get_error {
    my $self = shift;
    return $self->{has_error} || '';
};

=head3 get_tap

Return a would-be Test::More script output for current contract.

=cut

sub get_tap {
    my ($self, $verbosity) = @_;

    $verbosity = 1 unless defined $verbosity;
    my @str;
    foreach (@{ $self->{mess} }) {
        my ($indent, $lvl, $mess) = @$_;
        next unless $lvl <= $verbosity;

        my $pad  = $indent > 0 ? '    ' x $indent : '';
        $pad    .= $lvl > 0 ? '#' x $lvl . ' ' : '';
        $mess    =~ s/\s*$//s;

        foreach (split /\n/, $mess) {
            push @str, "$pad$_\n";
        };
    };
    return join '', @str;
};

=head3 get_sign

Produce a terse pass/fail summary (signature)
as a string of numbers and letters.

The format is C<"t(\d+|N)*[rdE]">.

=over

=item C<t> is always present at the start;

=item a number stands for a series of passing tests;

=item C<N> stands for a I<single> failing test;

=item C<r> stands for a contract that is still B<r>unning;

=item C<E> stands for a an B<e>xception during execution;

=item C<d> stands for a contract that is B<d>one.

=back

The format is still evolving.
Capital letters are used to represent failure,
and it is likely to stay like that.

The numeric notation was inspired by Forsyth-Edwards notation (FEN) in chess.

=cut

sub get_sign {
    my $self = shift;

    my @t = ("t");

    my $streak;
    foreach (1 .. $self->{count}) {
        if ( $self->{fail}{$_} ) {
            push @t, $streak if $streak;
            $streak = 0;
            push @t, "N"; # for "not ok"
        } else {
            $streak++;
        };
    };
    push @t, $streak if $streak;

    my $d = $self->get_error ? 'E' : $self->{done} ? 'd' : 'r';
    return join '', @t, $d;
};

=head2 DEVELOPMENT PRIMITIVES

Generally one should not touch these methods unless
when subclassing to build a new test backend.

When extending this module,
please try to stick to C<do_*>, C<get_*>, and C<set_*>
to avoid clash with test names.

This is weird and probably has to be fixed at some point.

=head3 do_log( $indent, $level, $message )

Append a message to execution log.
Levels are:

=over

=item -2 - something totally horrible

=item -1 - a failing test

=item 0 - a passing test

=item 1 - a diagnostic message, think C<Test::More/diag>

=item 2+ - a normally ignored verbose message, think L<Test::More/note>

=back

=cut

sub do_log {
    my ($self, $indent, $level, $mess) = @_;

    $self->_croak( $ERROR_DONE )
        if $self->{done};

    $indent += $self->{indent};

    push @{ $self->{mess} }, [$indent, $level, $mess];

    return $self;
};

=head2 get_log

Return log messages "as is" as array reference
containing triads of (indent, level, message).

B<[CAUTION]> This currently returns reference to internal structure,
so be careful not to spoil it.
This MAY change in the future.

=cut

sub get_log {
    my $self = shift;
    # TODO copy or smth
    return $self->{mess};
};

=head3 set_result( $id, $result )

Add a refutation to the failed tests log.

This is not guaranteed to be called for passing tests.

=cut

sub set_result {
    my ($self, $id, $result) = @_;

    $self->_croak( $ERROR_DONE )
        if $self->{done};
    $self->_croak( "Duplicate test id $id" )
        if exists $self->{fail}{$id};

    push @{ $self->{list} }, $id;
    $self->{fail_count}++ if $result;
    $self->{fail}{$id} = $result;

    return $self;
};

=head3 get_proxy

Return ($self, indent) pair in list content, or just $self in scalar context.

=cut

sub get_proxy {
    my $self = shift;

    return wantarray ? ($self, $self->{indent}) : $self;
};

sub _croak {
    my ($self, $mess) = @_;

    $mess ||= "Something terrible happened";
    $mess =~ s/\n+$//s;

    my $fun = (caller 1)[3];
    $fun =~ s/(.*)::/${1}->/;

    croak "$fun(): $mess";
};

=head2 DEPRECATED METHODS

The following methods were added in the beginning and will disappear
in 0.10.

=over

=item count       => "get_count"

=item add_result  => "set_result"

=item result      => "get_result"

=item last_error  => "get_error"

=item signature   => "get_sign"

=item as_tap      => "get_tap"

=item log_message => "do_log"

=back

=cut

_deprecate( count       => "get_count" );
_deprecate( add_result  => "set_result" );
_deprecate( result      => "get_result" );
_deprecate( last_error  => "get_error" );
_deprecate( signature   => "get_sign" );
_deprecate( as_tap      => "get_tap" );
_deprecate( log_message => "do_log" );

sub _deprecate {
    my ($legacy, $new) = @_;

    my $impl = \&$new;

    no strict 'refs';           ## no critic
    no warnings 'redefine';     ## no critic
    *$legacy = sub {
        carp "$legacy() is deprecated, use $new() instead";
        *$legacy = $impl;
        goto &$impl;            ## no critic
    };
};

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

1; # End of Assert::Refute::Exec

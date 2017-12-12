package Assert::Contract::Exec;

use 5.006;
use strict;
use warnings;
our $VERSION = 0.0104;

=head1 NAME

Assert::Contract - The great new Assert::Contract!

=head1 SYNOPSIS

    my $c = Assert::Contract::Exec;
    $c->refute ( $cond, $message );
    $c->refute ( $cond2, $message2 );
    # .......

    $c->count;      # how many tests were run
    $c->is_passing; # did any of them fail?
    $c->as_tap;     # return printable summary in familiar format

=cut

use Carp;

use Assert::Contract::Build::Util qw(to_scalar);

my $ERROR_DONE = "done_testing was called, no more changes may be added";

=head1 OBJECT-ORIENTED INTERFACE

=head2 new

    Assert::Contract::Exec->new( %options );

%options may include:

Nothing yet.

=cut

sub new {
    my ($class, %opt) = @_;

    bless {
        fail  => {},
        count => 0,
    }, $class;
};

=head2 RUNNING PRIMITIVES

=head3 refute( $condition, $message )

An inverted assertion. That is, it B<passes> if C<$condition> is B<false>.

=cut

sub refute {
    my ($self, $cond, $msg) = @_;

    $self->_croak( $ERROR_DONE )
        if $self->{done};

    $msg = $msg ? " - $msg" : '';
    my $n = ++$self->{count};

    if ($cond) {
        $self->{fail}{$n} = $cond;
        $self->log_message( -1, "not ok $n$msg" );
        $self->log_message(  1, $cond ) unless $cond eq 1;
        return 0;
    } else {
        $self->log_message( 0, "ok $n$msg" );
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

    $self->_croak( $ERROR_DONE )
        if $self->{done};
    $self->log_message( 1, join " ", map { to_scalar($_) } @_ );
};

sub note {
    my $self = shift;

    $self->_croak( $ERROR_DONE )
        if $self->{done};
    $self->log_message( 2, join " ", map { to_scalar($_) } @_ );
};

=head3 log_message( $level, $message )

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

sub log_message {
    my ($self, $level, @parts) = @_;

    $self->_croak( $ERROR_DONE )
        if $self->{done};
    foreach (@parts) {
        push @{ $self->{mess} }, [$level, $_];
    };

    return $self;
};

=head3 done_testing

Stop testing.
After this call, no more writes (including done_testing)
can be performed on this contract.
This happens by default at the end of C<contract{ ... }> block.

If an argument is given, it is considered to be the exception
that interrupted the contract execution,
resulting in an unconditionally failed contract.

=cut

sub done_testing {
    my ($self, $exception) = @_;

    if ($exception) {
        delete $self->{done};
        $self->{last_error} = $exception;
        # Make sure there *is* a failing test on the outside
        $self->refute( $exception, "unexpected exception: $exception" )
    } elsif ($self->{done}) {
        $self->_croak( $ERROR_DONE )
    };

    $self->{done}++;
    return $self;
};

=head2 INSPECTION PRIMITIVES

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

    return !%{ $self->{fail} } && !$self->{last_error};
};

=head3 count

How many tests have been executed.

=cut

sub count {
    my $self = shift;
    return $self->{count};
};

=head3 result( $n )

Returns result of $n-th test, dies if such test was never performed.
The result is false for passing tests and whatever the reason for failure was
for failing ones.

=cut

sub result {
    my ($self, $n) = @_;

    $self->_croak( "Test $n has never been performed" )
        unless $n =~ /^[1-9][0-9]*$/ and $n <= $self->{count};

    return $self->{fail}{$n} || 0;
};

=head3 has_died

Returns true if contract execution was ever interrupted by exception.

=cut

# TODO like, do we need this if we have last_error?
*has_died = *has_died = \&last_error;

=head3 last_error

Return last error that was recorded during contract execution,
or false if there was none.

=cut

sub last_error {
    my $self = shift;
    return $self->{last_error} || '';
};

=head3 as_tap

Return a would-be Test::More script output for current contract.

=cut

sub as_tap {
    my ($self, $verbosity) = @_;

    $verbosity = 1 unless defined $verbosity;
    my @str;
    foreach (@{ $self->{mess} }) {
        my ($lvl, $mess) = @$_;
        next unless $lvl <= $verbosity;
        my $pad = $lvl > 0 ? '#' x $lvl . ' ' : '';
        push @str, "$pad$mess";
    };
    return join "\n", @str, '';
};

=head3 signature

Produce a comparable string-based representation.

The format is C<"t...^^[Erd]">.

=over

=item C<t> is always present at the start;

=item C<.> stands for passing test;

=item C<^> stands for failing test;

=item C<r> stands for a running contract;

=item C<E> stands for a interrupted execution;

=item C<d> stands for a contract that is done.

=back

=cut

# TODO maybe chess-like: t5F2d meaning "5 passes, 1 fail, 2 passes"

sub signature {
    my $self = shift;

    my @t = map { $self->{fail}{$_} ? "^" : "." }
        1 .. $self->{count};
    my $d = $self->last_error ? 'E' : $self->{done} ? 'd' : 'r';
    return join '', "t", @t, $d;
};

sub _croak {
    my ($self, $mess) = @_;
    my @where = caller 0;

    my $fun = $where[3];
    $fun =~ s/.*:://;
    $mess ||= "Something terrible happened";
    $mess =~ s/\n+$//s;

    croak "$where[0]->$fun: $mess";
};

=head1 BUGS

Please report any bugs or feature requests to C<bug-assert-contract at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Assert-Contract>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the C<perldoc> command.

    perldoc Assert::Contract::Exec

You can also look for information at:

=over 4

=item * C<RT>: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Assert-Contract>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Assert-Contract>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Assert-Contract>

=item * Search CPAN

L<http://search.cpan.org/dist/Assert-Contract/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

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

1; # End of Assert::Contract::Exec

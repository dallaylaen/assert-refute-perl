package Assert::Contract::Engine::Build;

use strict;
use warnings;
our $VERSION = 0.0101;

=head1 NAME

Assert::Contract::Engine::Build - tool for extending Assert::Contract suite

=head1 DESCRIPTION

Unfortunately, extending L<Assert::Contract> is not completely straightforward.

In order to create a new test function, one needs to:

=over

=item * provide a check function that returns a false value on success
and a brief description of the problem on failure
(e.g. C<"$got != $expected">);

=item * build an exportable wrapper around it that would talk to
the most up-to-date L<Assert::Contract> instance;

=item * add a method with the same name to L<Assert::Contract>
so that object-oriented and functional interfaces
are as close to each other as possible.

=back

The first task still has to be done by a programmer (you),
but the other two can be more or less automated.
Hence this module.

=head1 SYNOPSIS

Extending the test suite goes as follows:

    package My::Package;
    use Assert::Contract::Engine::Build;
    use parent qw(Exporter);

    build_refute is_everything => sub {
        return if $_[0] == 42;
        return "$_[0] is not answer to life, universe, abd everything";
    }, export => 1, args => 1;

    1;

This can be later used either inside production code to check a condition:

    use Assert::Contract;
    use My::Package;
    my $c = contract {
        is_everything( $foo );
        $_[0]->is_everything( $bar ); # ditto
    };
    # ... check $c validity

The function provided to builder MUST
return a false value if everything is fine,
or reason of failure (but generally any true value) if not.

This call will create a prototyped function is_everything(...) in the calling
package, with C<args> positional parameters and an optional human-readable
message. (Think C<ok 1>, C<ok 1 'test passed'>).

=head1 FUNCTIONS

All functions are exportable.

=cut

use Carp;
use Scalar::Util qw(weaken blessed set_prototype looks_like_number refaddr);
use parent qw(Exporter);
our @EXPORT = qw(build_refute current_contract to_scalar);

use Assert::Contract::Spec;
use Assert::Contract::Build::Util qw(to_scalar);

=head2 build_refute name => CODE, %options

Create a function in calling package and a method in L<Assert::Contract>.
As a side effect, Assert::Contract's internals are added to the caller's
C<@CARP_NOT> array so that carp/croak points to actual outside usage.

B<NOTE> One needs to use Exporter explicitly if either C<export>
or C<export_ok> option is in use. This MAY change in the future.

Options may include:

=over

=item * C<export> => 1    - add function to @EXPORT
(Exporter still has to be used by target module explicitly).

=item * C<export_ok> => 1 - add function to @EXPORT_OK (don't export by default).

=item * C<no_create> => 1 - don't generate a function at all, just add to
L<Assert::Contract>'s methods.

=item * C<args> => C<nnn> - number of arguments.
This will generate a prototyped function
accepting C<nnn> scalars + optional description.

=item * C<list> => 1 - create a list prototype instead.
Mutually exclusive with C<args>.

=item * C<block> => 1 - create a block function.

=item * C<no_proto> => 1 - skip prototype, function will have to be called
with parentheses.

=back

=cut

my %Backend;
my %Carp_not;
my $trash_can = __PACKAGE__."::generated::For::Cover::To::See";
my %known;
$known{$_}++ for qw(args list block no_proto
    export export_ok no_create);

sub build_refute(@) { ## no critic # Moose-like DSL for the win!
    my ($name, $cond, %opt) = @_;

    my $class = "Assert::Contract::Exec";

    if (my $backend = ( $class->can($name) ? $class : $Backend{$name} ) ) {
        croak "build_refute(): '$name' already registered by $backend";
    };
    my @extra = grep { !$known{$_} } keys %opt;
    croak "build_refute(): unknown options: @extra"
        if @extra;
    croak "build_refute(): list and args options are mutually exclusive"
        if $opt{list} and defined $opt{args};

    my @caller = caller(1);
    my $target = $opt{target} || $caller[0];

    my $nargs = $opt{args} || 0;
    $nargs = 9**9**9 if $opt{list};

    $nargs++ if $opt{block};

    # TODO Add executability check if $block
    my $method  = sub {
        my $self = shift;
        my $message; $message = pop unless @_ <= $nargs;

        return $self->refute( scalar $cond->(@_), $message );
    };
    my $wrapper = sub {
        my $message; $message = pop unless @_ <= $nargs;
        return current_contract()->refute( scalar $cond->(@_), $message );
    };
    if (!$opt{no_proto} and ($opt{block} || $opt{list} || defined $opt{args})) {
        my $proto = $opt{list} ? '@' : '$' x ($opt{args} || 0);
        $proto = "&$proto" if $opt{block};
        $proto .= ';$' unless $opt{list};

        # '&' for set_proto to work on a scalar, not {CODE;}
        &set_prototype( $wrapper, $proto );
    };

    $Backend{$name}   = "$target at $caller[1] line $caller[2]"; # just for the record
    my $todo_carp_not = !$Carp_not{ $target }++;
    my $todo_create   = !$opt{no_create};
    my $export        = $opt{export} ? "EXPORT" : $opt{export_ok} ? "EXPORT_OK" : "";

    # Magic below, beware!
    no strict 'refs'; ## no critic # really need magic here

    # set up method for OO interface
    *{ $class."::$name" } = $method;

    # FIXME UGLY HACK - somehow it makes Devel::Cover see the code in report
    *{ $trash_can."::$name" } = $cond;

    if ($todo_create) {
        *{ $target."::$name" } = $wrapper;
        push @{ $target."::".$export }, $name
            if $export;
    };
    if ($todo_carp_not) {
        no warnings 'once';
        push @{ $target."::CARP_NOT" }, "Assert::Contract::Spec", $class;
    };

    # magic ends here

    return 1;
};

=head2 current_contract

Returns the contract object being executed.
Dies if no contract is being executed at the time.

This is actually a clone of L<Assert::Contract::Spec/current_contract>.

=cut

{
    no warnings 'once'; ## no critic
    *current_contract = \&Assert::Contract::Spec::current_contract;
}

=head1 LICENSE AND COPYRIGHT

This module is part of L<Assert::Contract> suite.

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

1;

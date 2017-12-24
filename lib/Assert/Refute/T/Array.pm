package Assert::Refute::T::Array;

use strict;
use warnings;
our $VERSION = 0.0401;

=head1 NAME

Assert::Refute::T::Array - Assertions about arrays for Assert::Refute suite

=head1 SYNOPSIS

Add C<array_of> and C<is_sorted> checks to both runtime checks
and unit test scripts.

    use Test::More;
    use Assert::Refute qw(:core);
    use Assert::Refute::T::Array;

Testing that array consists of given values:

    array_of [ "foo", "bar", "baz" ], qr/ba/, "This fails because of foo";

    array_of [
        { id => 42, name => "Answer to life" },
        { id => 137 },
    ], contract {
        package T;
        use Assert::Refute::T::Basic;
        like $_[0]->{name}, qr/^\w+$/;
        like $_[0]->{id}, qr/^\d+$/;
    }, "This also fails";

Testing that array is ordered:

    is_sorted { $a lt $b } [sort qw(foo bar bar baz)],
        "This fails because of repetition";
    is_sorted { $a le $b } [sort qw(foo bar bar baz)],
        "This passes though";

Not only sorting, but other types of partial order can be tested:

    is_sorted { $b->{start_date} eq $a->{end_date} }, \@reservations,
        "Next reservation aligned with the previous one";

=head1 EXPORTS

All of the below functions are exported by default:

=cut

use Carp;
use Scalar::Util qw(blessed);
use parent qw(Exporter);

our @EXPORT = qw(array_of);

use Assert::Refute::Build;
use Assert::Refute; # TODO oo interface in internals, plz

=head2 array_of

    array_of \@list, $criteria, [ "message" ]

Check that I<every> item in the list matches criteria, which may be one of:

=over

=item * regex - just match against regular expression;

=item * L<Assert::Refute::Contract> - pass list element to this contract as
argument.

=back

=cut

my $is_list = contract {
    my ($list, $match) = @_;

    if (ref $match eq 'Regexp') {
        foreach (@$list) {
            like $_, $match;
        };
    } elsif (blessed $match) {
        foreach (@$list) {
            subcontract "list item" => $match, $_;
        };
    } else {
        croak "Unknown criterion type: ".(ref $match || 'SCALAR');
    };
};

sub array_of ($$;$) { ## no critic
    my ($list, $match, $message) = @_;

    $message ||= "list of";
    return subcontract $message => $is_list, $list, $match;
}


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

1;

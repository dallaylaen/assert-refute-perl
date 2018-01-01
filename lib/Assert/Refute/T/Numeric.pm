package Assert::Refute::T::Numeric;

use strict;
use warnings;
our $VERSION = 0.07;

=head1 NAME

Assert::Refute::T::Numeric - Numeric tests for Assert::Refute suite.

=head1 SYNOPSIS

Somewhere in your unit-test:

    use Test::More;
    use Assert::Refute::T::Numeric; # must come *after* Test::More

    is_between 4 * atan2( 1, 1 ), 3.1415, 3.1416, "Pi number as expected";

    within_delta sqrt(sqrt(sqrt(10)))**8, 10, 1e-9, "floating point round-trip";

    within_relative 2**20, 1_000_000, 0.1, "10% precision for 1 mbyte";

    done_testing;

Same for production code:

    use Assert::Refute;
    use Assert::Refute::T::Numeric;

    my $rotate = My::Rotation::Matrix->new( ... );
    refute_these {
        within_delta $rotate->determinant, 1, 1e-6, "Rotation keeps distance";
    };

    my $total = calculate_price();
    refute_these {
        is_between $total, 1, 100, "Price within reasonable limits";
    };

=cut

use Carp;
use Scalar::Util qw(looks_like_number);
use parent qw(Exporter);

use Assert::Refute::Build;

=head2 is_between $x, $lower, $upper, [$message]

Note that $x comes first and I<not> between boundaries.

=cut

build_refute is_between => sub {
    my ($x, $min, $max) = @_;

    croak "Non-numeric boundaries: ".to_scalar($min, 0).",".to_scalar($max, 0)
        unless looks_like_number $min and looks_like_number $max;

    return "Not a number: ".to_scalar($x, 0)
        unless looks_like_number $x;

    return $min <= $x && $x <= $max ? '' : "$x is not in [$min, $max]";
}, args => 3, export => 1;

=head2 within_delta $x, $expected, $delta, [$message]

Test that $x differs from $expected value by no more than $delta.

=cut

build_refute within_delta => sub {
    my ($x, $exp, $delta) = @_;

    croak "Non-numeric boundaries: ".to_scalar($exp, 0)."+-".to_scalar($delta, 0)
        unless looks_like_number $exp and looks_like_number $delta;

    return "Not a number: ".to_scalar($x, 0)
        unless looks_like_number $x;

    return abs($x - $exp) <= $delta ? '' : "$x is not in [$exp +- $delta]";
}, args => 3, export => 1;

=head2 within_relative $x, $expected, $delta, [$message]

Test that $x differs from $expected value by no more than $expected * $delta.

=cut

build_refute within_relative => sub {
    my ($x, $exp, $delta) = @_;

    croak "Non-numeric boundaries: ".to_scalar($exp, 0)."+-".to_scalar($delta, 0)
        unless looks_like_number $exp and looks_like_number $delta;

    return "Not a number: ".to_scalar($x, 0)
        unless looks_like_number $x;

    return abs($x - $exp) <= abs($exp * $delta)
        ? ''
        : "$x differs from $exp by more than ".$exp*$delta;
}, args => 3, export => 1;

=head1 SEE ALSO

L<Test::Number::Delta>.

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

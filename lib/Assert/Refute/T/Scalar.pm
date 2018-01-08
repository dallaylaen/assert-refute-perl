package Assert::Refute::T::Scalar;

use strict;
use warnings;
our $VERSION = 0.0701;

=head1 NAME

Assert::Refute::T::Scalar - Assertions about scalars for Assert::Refute suite.

=head1 SYNOPSIS

Currently only one check exists in this package, C<maybe_is>.

    use Test::More;
    use Assert::Refute::T::Scalar;

    maybe_is $foo, undef,          'Only passes if $foo is undefined';
    maybe_is $bar, 42,             'Only if undef or exact match';
    maybe_is $baz, qr/.../,        'Only if undef or matches regex';
    maybe_is $quux, sub { ok $_ }, 'Only if all refutations hold for $_';

    done_testing;

=head1 EXPORTS

All of the below functions are exported by default:

=cut

use Carp;
use parent qw(Exporter);

use Assert::Refute::Build;

=head2 maybe_is $value, $condition, "message"

Pass if value is C<undef>, apply condition otherwise.

Condition can be:

=over

=item * C<undef> - only undefined value fits;

=item * a plain scalar - an exact match expected (think C<is>);

=item * a regular expression - match it (think C<like>);

=item * anything else - assume it's subcontract.
The value in question will be passed as I<both> an argument and C<$_>.

=back

B<[EXPERIMENTAL]> This function may be removed for good
if it turns out too complex (I<see smartmatch debacle in Perl 5.27.7>).

=cut

build_refute maybe_is => sub {
    my ($self, $var, $cond, $message) = @_;

    return $self->refute(0, $message) unless defined $var;
    return $self->is( $var, $cond ) unless ref $cond;
    return $self->like( $var, $cond ) if ref $cond eq 'Regexp';

    $message ||= "maybe_is";
    local $_ = $var;
    return $self->subcontract( $message => $cond, $_ );
}, manual => 1, args => 2, export => 1;

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

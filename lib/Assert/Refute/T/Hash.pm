package Assert::Refute::T::Hash;

use strict;
use warnings;
our $VERSION = 0.08;

=head1 NAME

Assert::Refute::T::Hash - Assertions about hashes for Assert::Refute suite

=head1 SYNOPSIS

    use Test::More;
    use Assert::Refute::T::Hash;

    keys_are { foo => 42, bar => 137 }, ["foo"], ["bar"], "Hash keys as expected";

=head1 EXPORTS

All of the below functions are exported by default:

=cut

use Carp;
use Scalar::Util qw(blessed);
use parent qw(Exporter);
our @EXPORT = qw(values_are);

use Assert::Refute::Build;
use Assert::Refute qw(:all); # TODO Assert::Refute::Contract please

=head2 keys_are \%hash, \@required, \@allowed, "Message"

Check that keys in hash are exactly as expected:

=over

=item * if \@required is present, make sure that all keys listed there exist;

=item * if \@allowed is present, make sure no keys are present
except those listed in either required or allowed.

=back

=cut

build_refute keys_are => sub {
    my ($hash, $required, $allowed) = @_;

    $required ||= [];

    my @missing = grep { !exists $hash->{$_} } @$required;
    my @extra;
    if ($allowed) {
        my %seen;
        $seen{$_}++ for @$required, @$allowed;
        @extra = grep { !exists $seen{$_} } keys %$hash;
    };

    my @msg;
    push @msg, "Required keys missing (@missing)" if @missing;
    push @msg, "Unexpected keys present (@extra)" if @extra;
    return join "; ", @msg;
}, args => 3, export => 1;

=head2 values_are \%hash, \%spec

For each key in %spec, check corresponding value in %hash:

=over

=item * if spec is C<undef>, only accept undefined or missing value;

=item * if spec is a string or number, check exact match (C<is>);

=item * if spec is a regular expression, apply it (C<like>);

=item * if spec is a contract or sub, apply it to the value (C<subcontract>);

=back

B<[NOTE]> This test should die if any other value appears in the spec.
However, it does not yet, instead producing a warning and
an unconditionally failed test.

=cut

build_refute values_are => sub {
    my ($self, $hash, $spec, $message) = @_;

    $message ||= "hash values as expected";
    $self->subcontract( $message => sub {
        foreach ( keys %$spec ) {
            my $cond = $spec->{$_};
            if (!ref $cond) {
                is $hash->{$_}, $cond, "$_ exact value";
            } elsif (ref $cond eq 'Regexp') {
                like $hash->{$_}, $cond, "$_ regex";
            } elsif (blessed $cond or UNIVERSAL::isa($cond, 'CODE')) {
                subcontract "$_ contract" => $cond, $hash->{$_};
            } else {
                # TODO bail_out when we can
                carp  "FIX TEST! Unexpected value in spec: '$_'=". ref $cond;
                croak "FIX TEST! Unexpected value in spec: '$_'=". ref $cond;
            };
        };
    });
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

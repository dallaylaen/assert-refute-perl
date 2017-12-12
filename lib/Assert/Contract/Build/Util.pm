package Assert::Contract::Build::Util;

use strict;
use warnings;
our $VERSION = 0.0101;

=head1 NAME

Assert::Contract::Build::Util - utility functions for Assert::Contract

=head1 DESCRIPTION

See L<Assert::Contract> and L<Assert::Contract::Build>.
Nothing of interest here.

=head1 FUNCTIONS

All functions are exportable.

=cut

use Carp;
use Scalar::Util qw(weaken blessed set_prototype looks_like_number refaddr);
use parent qw(Exporter);
our @EXPORT = qw(to_scalar);

=head2 to_scalar

=over

=item * C<to_scalar( undef )> # returns C<'(undef)'>

=item * C<to_scalar( string )> # returns the string as is in quotes

=item * C<to_scalar( \%ref || \@array, $depth )>

Represent structure as string.
Only goes C<$depth> levels deep. Default depth is 1.

=back

Convert an unknown data type to a human-readable string.

Hashes/arrays are only penetrated 1 level deep.

C<undef> is returned as C<"(undef)"> so it can't be confused with other types.

Strings are quoted unless numeric.

Refs returned as C<My::Module/1a2c3f>

=cut

my %replace = ( "\n" => "n", "\\" => "\\", '"' => '"', "\0" => "0", "\t" => "t" );
sub to_scalar {
    my ($data, $depth) = @_;

    return '(undef)' unless defined $data;
    if (!ref $data) {
        return $data if !defined $depth or looks_like_number($data);
        $data =~ s/([\0"\n\t\\])/\\$replace{$1}/g;
        $data =~ s/([^\x20-\x7E])/sprintf "\\x%02x", ord $1/ge;
        return "\"$data\"";
    };

    $depth = 1 unless defined $depth;

    if ($depth) {
        if (UNIVERSAL::isa($data, 'ARRAY')) {
            return (ref $data eq 'ARRAY' ? '' : ref $data)
                ."[".join(", ", map { to_scalar($_, $depth-1) } @$data )."]";
        };
        if (UNIVERSAL::isa($data, 'HASH')) {
            return (ref $data eq 'HASH' ? '' : ref $data)
            . "{".join(", ", map {
                 to_scalar($_, 0) .":".to_scalar( $data->{$_}, $depth-1 );
            } sort keys %$data )."}";
        };
    };
    return sprintf "%s/%x", ref $data, refaddr $data;
};

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

package Assert::Refute::T::Deep;

use 5.006;
use strict;
use warnings;
our $VERSION = 0.0104;

=head1 NAME

Assert::Refute::Basic::Deep - is_deeply method for Assert::Refute suite.

=head1 SYNOPSIS

In this example we ensure that two implementations of the same function
produce identical output.

    use Assert::Refute qw(:core to_scalar);
    use Assert::Refute::T::Deep;

    my $check = contract {
        my $arg = shift;
        my $expected = naive_impl( $arg );
        is_deeply fast_impl( $arg ), $expected, "fast_impl ok for";
    };

=head1 DESCRIPTION

Add C<is_deeply> method to L<Assert::Refute> and L<Assert::Refute>.

=cut

use Scalar::Util qw(refaddr);
use parent qw(Exporter);

use Assert::Refute::Build;

our @EXPORT_OK = qw(deep_diff);

=head2 is_deeply( $got, $expected )

=cut

build_refute is_deeply => sub {
    my $diff = deep_diff( shift, shift );
    return unless $diff;
    return "Structures differ (got != expected):\n$diff";
}, export => 1, args => 2;


=head2 deep_diff( $old, $new )

Returns a true scalar if structures differ.

=cut

sub deep_diff {
    my ($old, $new, $known, $path) = @_;

    $known ||= {};
    $path ||= '&';

    # TODO combine conditions, too much branching
    # diff refs => isn't right away
    if (ref $old ne ref $new or (defined $old xor defined $new)) {
        return join "!=", to_scalar($old), to_scalar($new);
    };

    # not deep - return right away
    return '' unless defined $old;
    if (!ref $old) {
        return $old ne $new && join "!=", to_scalar($old), to_scalar($new),
    };

    # recursion
    # check topology first to avoid looping
    # new is likely to be simpler (it is the "expected" one)
    # FIXME BUG here - if new is tree, and old is DAG, this code won't catch it
    if (my $new_path = $known->{refaddr $new}) {
        my $old_path = $known->{-refaddr($old)};
        return to_scalar($old)."!=$new_path" unless $old_path;
        return $old_path ne $new_path && "$old_path!=$new_path";
    };
    $known->{-refaddr($old)} = $path;
    $known->{refaddr $new} = $path;

    if (UNIVERSAL::isa( $old , 'ARRAY') ) {
        my @diff;
        for (my $i = 0; $i < @$old || $i < @$new; $i++ ) {
            my $off = deep_diff( $old->[$i], $new->[$i], $known, $path."[$i]" );
            push @diff, "$i:$off" if $off;
        };
        return @diff ? _array2str( \@diff, ref $old ) : '';
    };
    if (UNIVERSAL::isa( $old, 'HASH') ) {
        my ($both_k, $old_k, $new_k) = _both_keys( $old, $new );
        my %diff;
        $diff{$_} = to_scalar( $old->{$_} )."!=(none)" for @$old_k;
        $diff{$_} = "(none)!=".to_scalar( $new->{$_} ) for @$new_k;
        foreach (@$both_k) {
            my $off = deep_diff( $old->{$_}, $new->{$_}, $known, $path."{$_}" );
            $diff{$_} = $off if $off;
        };
        return %diff ? _hash2str( \%diff, ref $old ) : '';
    };

    # finally - don't know what to do, compare refs
    $old = to_scalar($old);
    $new = to_scalar($new);
    return $old ne $new && join "!=", $old, $new;
};

sub _hash2str {
    my ($hash, $type) = @_;
    $type = '' if $type eq 'HASH';
    return $type.'{'
            . join(", ", map { to_scalar($_).":$hash->{$_}" } sort keys %$hash)
        ."}";
};

sub _array2str {
    my ($array, $type) = @_;
    $type = '' if $type eq 'ARRAY';
    return "$type\[".join(", ", @$array)."]";
};

# in: hash + hash
# out: common keys +
sub _both_keys {
    my ($old, $new) = @_;
    # TODO write shorter
    my %uniq;
    $uniq{$_}++ for keys %$new;
    $uniq{$_}-- for keys %$old;
    my (@o_k, @n_k, @b_k);
    foreach (sort keys %uniq) {
        if (!$uniq{$_}) {
            push @b_k, $_;
        }
        elsif ( $uniq{$_} < 0 ) {
            push @o_k, $_;
        }
        else {
            push @n_k, $_;
        };
    };
    return (\@b_k, \@o_k, \@n_k);
};

=head1 LICENSE AND COPYRIGHT

This module is part of L<Refute::Assert> suite.

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

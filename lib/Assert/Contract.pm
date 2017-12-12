package Assert::Contract;

use 5.006;
use strict;
use warnings;
our $VERSION = 0.0103;

=head1 NAME

Assert::Contract - Test::More-like assertions in your production code

=head1 SYNOPSIS

    use Assert::Contract;

    my $spec = contract {
        my ($foo, $bar) = @_;
        is $foo, 42, "Life";
        like $bar, qr/b.*a.*r/, "Regex";
    };

    # later
    my $report = $spec->exec( 42, "bard" );
    $report->count;      # 2
    $report->is_passing; # true
    $report->as_tap;     # printable summary *as if* it was Test::More

=head1 DESCRIPTION

This module adds C<Test::More>-like snippets to your production code.

Such snippet is compiled once and executed multiple times,
generating reports objects that can be queried to be successful
or printed out as TAP if needed.

=head1 EXPORT

All functions in this module are exportable and exported by default.
See L<Assert::Contract::Spec> for object-oriented interface
if you insist on leaving the namespace clean.

=cut

use Carp;
use Exporter;

use Assert::Contract::Spec;
use Assert::Contract::T::Basic;
use Assert::Contract::T::Deep;

my @basic = (
    @Assert::Contract::T::Basic::EXPORT,
    @Assert::Contract::T::Deep::EXPORT,
);
my @core  = qw(contract current_contract);

our @ISA = qw(Exporter);
our @EXPORT = (@core, @basic);

our %EXPORT_TAGS = (
    basic => \@basic,
    core  => \@core,
);

=head2 contract { ... }

Create a contract specification object for future use.
The form is

    my $spec = contract {
        my @args = @_;
    };

    my $spec = contract {
        my ($contract, @args) = @_;
    } want_self => 1;

The want_self form may be preferable if one doesn't want to pollute the
main namespace with test functions (C<is>, C<ok>, C<like> etc)
and instead intends to use object-oriented interface.

Other options are TBD.

=cut

sub contract (&@) { ## no critic
    my ($todo, %opt) = @_;

    # TODO check
    $opt{code} = $todo;
    return Assert::Contract::Spec->new( %opt );
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

=head1 BUGS

Please report any bugs or feature requests to C<bug-assert-contract at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Assert-Contract>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the C<perldoc> command.

    perldoc Assert::Contract

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

1; # End of Assert::Contract

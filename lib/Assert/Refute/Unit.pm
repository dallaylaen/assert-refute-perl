package Assert::Refute::Unit;

use strict;
use warnings;
our $VERSION = 0.0401;

=head1 NAME

Assert::Refute::Unit - unit-testing framework based on Assert::Refute

=cut

use Carp;
use parent qw(Exporter);
use Assert::Refute 0.04 qw(:core :basic);
use Assert::Refute::Driver::Print;
our @EXPORT = (@Assert::Refute::EXPORT, "done_testing");

$Assert::Refute::Build::BACKEND ||= Assert::Refute::Driver::Print->new;

=head2 done_testing

A done_testing call MUST be present at the end of the test script.

=cut

sub done_testing {
    current_contract->done_testing;
};

END {
    my $be = $Assert::Refute::Build::BACKEND;
    if ($be and $be->isa('Assert::Refute::Driver::Print')) {
        if (!scalar @{ $be->get_log || [] } ) {
            # pass
        } elsif( !$be->is_done ) {
            $be->done_testing("no plan");
            exit 100;
        } elsif ( !$be->is_passing ) {
            my $fail = $be->get_fail_count;
            exit $fail > 99 ? 99 : $fail;
        };
    };
};

1;

#!perl

use strict;
use warnings;
use Test::More;
BEGIN{
    $ENV{NO_DEVELOPMENT} = "Some weird reason";
};

use Assert::Refute {};

my $report = try_refute {
    refute [ 42, 137 ], "Life is fine";
};

ok $report->is_passing, "Report still passing though it shouldn't";

like $report->get_tap, qr/# SKIP\b.*\bSome weird reason/, "Reason preserved";

done_testing;

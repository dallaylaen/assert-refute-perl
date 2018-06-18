#!perl

use strict;
use warnings;
use Test::More;
use Assert::Refute::T::Errors;
use Assert::Refute::Report;

my $ex = Assert::Refute::Report->new;

warns_like {
    is $ex->count, 0, "No tests this far";
} qr/count.*deprecated.*get_count/, "count deprecated, alternative suggested";

warns_like {
    $ex->log_message( 1, -1, "Padded diag" );
} qr/log_message.*deprecated.*do_log/
    , "log_message deprecated, alternative suggested";

warns_like {
    is $ex->as_tap, "    # Padded diag\n", "Output as expected";
} qr/as_tap.*deprecated.*get_tap/, "as_tap deprecated, alternative suggested";

done_testing;

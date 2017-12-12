#!perl

use strict;
use warnings;
use Test::More;

use Assert::Contract;

my $spec = contract {
    current_contract->refute( 0, "fine" );
    current_contract->refute( 42, "not so fine" );
};

my $log = $spec->exec;

is $log->count, 2, "Count as expected";
ok !$log->is_passing, "Contract invalidated (as expected)";

my $permitted = eval {
    current_contract;
    "Should not be";
};
like $@, qr/[Nn]ot currently testing anything/, "Thou shall not pass";
is $permitted, undef, "Unreachable";

done_testing;

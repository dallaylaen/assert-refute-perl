#!perl

use strict;
use warnings;
use Test::More;

use Assert::Refute::Exec;

my $c = Assert::Refute::Exec->new;

ok $c->is_passing, "passing: empty = ok";
is $c->get_count, 0, "0 tests run";
is $c->get_fail_count, 0, "0 of them failed";

ok $c->refute( 0, "right" ), "refute(false) yelds true";
ok $c->is_passing, "still passing";
ok !$c->refute( "foobared", "wrong" ), "refute(false) yelds true";
ok !$c->is_passing, "not passing now";
is $c->get_count, 2, "2 tests now";
is $c->get_fail_count, 1, "1 of them failed";

like $c->get_tap, qr/^ok 1 - right\nnot ok 2 - wrong\n# .*foobared.*\n$/s,
    "get_tap looks like tap";

$c->done_testing;
like $c->get_tap, qr/\n1..2(\n|$)/, "Plan present";

eval {
    $c->done_testing;
};

like $@, qr/Assert::Refute::Exec->done_testing.*done_testing.*no more/
    , "done_testing locks execution log";

done_testing;

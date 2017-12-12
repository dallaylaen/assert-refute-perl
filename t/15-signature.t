#!perl

use strict;
use warnings;
use Test::More;

use Assert::Contract qw(:core);

my $c = contract {
    my $c = shift;
    $c->is( shift, 42 );
    $c->like( shift, qr/foo/ );
    die "Intentional" if shift;
} want_self=>1;

is $c->exec( 42, "food" )->signature, "t..", "Passing contract";

is $c->exec( 42, "bard" )->signature, "t.^", "Failing contract";

is $c->exec( 42, "food", "kaboom" )->signature, "t..^", "Exception => fail";

done_testing;

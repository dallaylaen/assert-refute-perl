#!perl

use strict;
use warnings;
use Test::More;

use Assert::Contract;

my $spec = Assert::Contract->new( code => sub {
    my $c = shift;
    $c->refute( shift, shift );
    die if shift;
} );

ok  $spec->exec( 0, "fine" )->is_passing, "Good";
ok !$spec->exec( 1, "not so fine" )->is_passing, "Bad";
ok !$spec->exec( 0, "fine", "die" )->is_passing, "Ugly";

done_testing;

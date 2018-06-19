#!perl

use strict;
use warnings;
use Test::More;

use Assert::Refute::Report;

my $c = Assert::Refute::Report->new( indent => 1 );

$c->refute (0);
$c->diag( "Foobar" );
$c->done_testing;

is $c->get_tap, <<"TAP", "Tap indented as intended";
    ok 1
    # Foobar
    1..1
TAP

done_testing;

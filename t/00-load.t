#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    require_ok( 'Assert::Contract' ) || print "Bail out!\n";
}

diag( "Testing Assert::Contract $Assert::Contract::VERSION, Perl $], $^X" );

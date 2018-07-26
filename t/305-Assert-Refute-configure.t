#!perl

use strict;
use warnings;
BEGIN{ delete @ENV{qw(NDEBUG PERL_NDEBUG)} };
use Test::More;
use Assert::Refute::T::Errors;

use Assert::Refute qw();

my $sub = sub { warn "Foobared" };

{
    package T;
    Assert::Refute->configure({on_pass=>$sub});
};

is( Assert::Refute->get_config( "T" )->{on_pass}, $sub
    , "get_config another package" );

ok( !Assert::Refute->get_config()->{on_pass}, "get_config caller - gets empty" );

dies_like {
    package T;
    Assert::Refute->configure( { foobared => 137 } );
} qr/Assert::Refute.*[Uu]nknown.*foobared/, "Unknown param = no go";

done_testing;

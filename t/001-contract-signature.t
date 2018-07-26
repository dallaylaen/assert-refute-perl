#!perl

use strict;
use warnings;
BEGIN{ delete @ENV{qw(NDEBUG PERL_NDEBUG)} };
use Test::More tests => 1;

my $sig = eval {
    package T;
    require Assert::Refute;
    Assert::Refute->import();
    my $c = contract( sub {
        my $c = shift;
        $c->is($_, 42) for @_;
    }, need_object => 1 )->apply(42, 137)->get_sign;
};

is $sig, "t1Nd", "Signature as expected" or do {
    diag "Exception was: $@" if $@;
    print "Bail out! Signature fails\n";
};

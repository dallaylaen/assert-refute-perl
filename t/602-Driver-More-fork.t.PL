#!perl

BEGIN {
    open STDERR, ">&", \*STDOUT;
};

use strict;
use warnings;
use Test::More;

use Assert::Refute qw(:core);


current_contract()->note("Testing test::more integration");
ok 1, "Intermix 1";
eval {
    refute 0, "Test pass";
};
is $@, '', "No exception";
ok 1, "Intermix 3";
eval {
    refute "Big and hairy reason", "Test fail";
};
is $@, '', "No exception (2)";
ok 1, "Intermix 5";
done_testing;

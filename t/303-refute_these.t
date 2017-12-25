#!perl

use strict;
use warnings;
use Test::More tests => 2;

use Assert::Refute::T::Errors;

{
    package T;
    use Assert::Refute qw(:all);
};

warns_like {
    package T;
    refute_these {
        refute 1, "This shouldn't be output";
    };
} qr/not ok 1.*1..1.*[Cc]ontract failed/s, "Warning as expected";

warns_like {
    package T;
    refute_these {
        refute 0, "This shouldn't be output";
    };
} [], "Warning as expected";


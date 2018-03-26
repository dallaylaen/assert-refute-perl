#!perl

use strict;
use warnings;
use Test::More tests => 2;
use Assert::Refute::T::Errors;

warns_like {
    package T;
    use Assert::Refute;

    refute_these {
        refute 1, "This fails";
    };
} [qr/refute_these.*configure.*DEPRECATED/, qr/not ok 1 - This fails/], "Deprecated + failure auto-warns";

warns_like {
    package T2;
    use Assert::Refute;

    refute_these {
        refute 0, "This passes";
    };
} qr/refute_these.*configure.*DEPRECATED/, "Only deprecated warning";



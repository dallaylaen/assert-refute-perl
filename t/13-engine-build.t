#!perl

use strict;
use warnings;
use Test::More;

use Assert::Contract;

# emulate use Foo;
BEGIN {
    package Foo;
    use base qw(Exporter);

    use Assert::Contract::Engine::Build;

    build_refute my_is => sub {
        my ($got, $exp) = @_;
        return $got eq $exp ? '' : to_scalar ($got) ." ne ".to_scalar ($exp);
    }, args => 2, export => 1;
};
BEGIN {
    Foo->import;
};

my $spec = contract {
    my $c = shift; # TODO remove
    my_is shift, 137, "Fine";
};

my $report = $spec->exec( 137 );
ok $report->is_passing, "137 is fine";

   $report = $spec->exec( 42 );
ok !$report->is_passing, "Life is not fine";

note $report->as_tap;

done_testing;

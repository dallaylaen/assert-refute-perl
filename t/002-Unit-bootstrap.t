#!perl

use strict;
use warnings FATAL => 'all';

my ($count, $fail) = (0,0);

eval {
    my $mod = 'Assert/Refute.pm';
    require $mod;
    my $path = $INC{$mod};
    $path =~ s#\Q$mod\E$##
        or die "Failed to find where $mod was loaded from";

    print "# Found $mod at $path\n";

    my @perl = (
        "perl",
        "-Mstrict",
        "-Mwarnings=FATAL,all",
        "-I$path",
        "-MAssert::Refute::Unit",
        "-e",
    );

    cmd_is( [@perl, "done_testing"], 0, "1..0\n");
    cmd_is( [@perl, "ok 1; done_testing"], 0, "ok 1\n1..1\n");
    cmd_is( [@perl, "ok 0; done_testing"], 1
        , "not ok 1\n1..1\n# Looks like 1 tests of 1 have failed\n");
    cmd_is( [@perl, "ok 1;"], 100 , "ok 1\nnot ok 2 - unexpected exception: no plan\n", 1);
    cmd_is( [@perl, "diag q{Foo}; done_testing"], 0, "# Foo\n1..0\n" );
    cmd_is( [@perl, "note q{Foo}; done_testing"], 0, "## Foo\n1..0\n" );
};

if ($@) {
    print "Bail out! # $@";
    exit 2;
} elsif ($fail) {
    print "Bail out! # Bootstrap tests failed\n";
    exit 1;
};

print "1..$count\n";
exit 0;

# All folks

sub cmd_is {
    my ($cmd, $exit, $exp, $strip) = @_;

    my $pid = open my $fd, '-|', @$cmd
        or die "Failed to run '@$cmd': $!";

    my @out;
    while (<$fd>) {
        push @out, $_;
    };
    my $got = join '', @out;

    if ($strip) {
        $got =~ s/#[^\n]*\n//gs;
    };

    my $cond = '';
    if ($^O ne 'MSWin32') {
        waitpid $pid, 0 or die "Waitpid failed: $!";
        $? >> 8 != $exit and $cond .= "Exit code ".($?>>8).", expected $exit\n";
    };

    $got eq $exp or $cond .= "GOT:\n$got\nEXPECTED:\n$exp\n";

    refute( $cond, "run @$cmd" );
};

sub refute {
    my ($reason, $message) = @_;

    $count++;
    print $reason ? "not ok $count - $message\n" : "ok $count - $message\n";
    if ($reason) {
        print "# $_\n" for split /\n/, $reason;
        $fail++;
    };
    return !$reason;
};

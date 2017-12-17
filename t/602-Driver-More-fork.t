#!perl

use strict;
use warnings;

use Test::More;

$ENV{PERL5LIB} = join ":", @INC;
my $pid = open my $read, '-|', "perl ".__FILE__.".PL";
$pid or die "Popen failed: $!";

my @out;
while (<$read>) {
    push @out, $_;
};
my $stdout = join '', @out;
$stdout or die "Failed to read pipe: $!";

$pid == waitpid( $pid, 0 )
    or die "Failed to waitpid: $!";
my $exit = $? >> 8;
my $sig  = $? & 128;

# finally!
note( "### CHILD REPLY ###" );
note( $stdout );
note( "### END CHILD REPLY ###" );

is (  $exit, 1, "1 test fail + no signal" );
is (  $sig,  0, "1 test fail + no signal" );
like( $stdout, qr/# *Testing.*integration\n/, "Note worked");
like( $stdout, qr/Intermix 1.*Test pass.*Intermix 3.*Test fail.*#[^\n]*Big and hairy reason.*Intermix 5.*\n1..\d+/s, "Test maybe worked" );

unlike( $stdout, qr/not ok.*exception/, "Nothing died in process" );

done_testing();

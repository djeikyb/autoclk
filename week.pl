#!/usr/bin/env perl

use warnings;
use strict;

use Config::Tiny;
use Expect;
use POSIX qw/strftime/;

my $file = "auth.conf";
my $start = "021113";
my $end = "021713";


# read credentials from file
my $Config = Config::Tiny->read($file);
my $pass = $Config->{_}->{password}
  or die "Can't read password from $file. $!\n";
my $user = $Config->{_}->{username}
  or die "Can't read username from $file. $!\n";


# init expect
my $exp = new Expect;
$exp->raw_pty(0);
$exp->spawn("tn5250", "district.gps")
  or die "Can't spawn: $!\n";
$exp->log_stdout(0);

# log in to timeclk
$exp->expect(1, 'User  . . . . . . . . . . . . . .   ');
$exp->send("timeclk\ttimeclk\r");

# ask for employee inquiry
$exp->send("\[21~"); # send F10
$exp->send("$user\t$pass");
$exp->send("$start$end\r");

# we're gonna look for a date next
# look for february as 2, not 02
my $today = strftime("%m/%d/%y", localtime);
$today =~ s/^0//;

# clear all the previous crap and get the result screen
$exp->clear_accum();
$exp->expect(1, $today);  # this is on the date picker screen
$exp->expect(1, $today);  # this is on the result screen
$exp->expect(1, "11=Charge");
my $bar = $exp->before();
$exp->hard_close();


# ESC[10;2H means put the following on line 10 of this screen
# we don't care which line of what screen
# so convert them all to newlines
$bar =~ s/\e\[\d+;2H/\n /g;
$bar =~ s/\e\[?.*?[\@-~]//g;
$bar =~ s///g;
print("$bar\n");


#original expect source
#
##!/bin/expect -f
#
#spawn tn5250 district.gps
#set output ""
#expect "User  . . . . . . . . . . . . . .   "
#send "timeclk\ttimeclk\r"
#send "\[21~"
## TODO replace user/pass and time range with vars
#send "xxxxxx\txxxx021113021713\r"
#expect "Timekeeper"
#expect "F17=Accruals"
##interact
#append output $expect_out(buffer)
#send_user "$output"
#close

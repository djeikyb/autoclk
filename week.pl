#!/usr/bin/env perl

use warnings;
use strict;

use DateTime;
use Config::Tiny;
use Expect;

my $file = "autoclk.conf";
my $tz = "-0700";

my $start = "";
my $end = "";

my $user = "";
my $pass = "";

sub main()
{
    ($start, $end) = getRange();
    ($user, $pass) = getLogin();
    print(unescape(getRaw()));
}

sub unescape()
{
    my ($str) = @_;

    # ESC[10;2H means put the following on line 10 of this screen
    # we don't care which line of what screen
    # so convert them all to newlines
    $str =~ s/\e\[\d+;2H/\n /g;

    # remove remaining ansi escapes
    $str =~ s/\e\[?.*?[\@-~]//g;

    # the kronos output uses ^O as a field delimiter. since parse.pl
    # uses substr, kill it
    $str =~ s///g;

    return $str;
}

sub getRange()
{
    #my $now = DateTime->now(time_zone=>$tz);

    my $now = now DateTime (time_zone=>$tz);

    my $monday = $now->clone()->subtract(days => ($now->wday - 1));
    my $sunday = $now->clone()->add(days => (7 - $now->wday));

    #my $monday = clone

    #subtract $monday (days => 7);
    #subtract $sunday (days => 7);

    #$monday->subtract(days => 7);
    #$sunday->subtract(days => 7);

    my $pattern = "MMddyy";

    return ($monday->format_cldr($pattern), $sunday->format_cldr($pattern));
}

sub getLogin()
{
    # read credentials from file
    my $Config = Config::Tiny->read($file);
    my $user = $Config->{_}->{username}
        or die "Can't read username from $file. $!\n";
    my $pass = $Config->{_}->{password}
        or die "Can't read password from $file. $!\n";

    return ($user, $pass);
}

sub getRaw()
{
    my $result = "";

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

    # we're gonna look for a date next (look for feb as 2, not 02)
    my $today = DateTime->now(time_zone=>$tz)->format_cldr("M/dd/yy");

    # clear all the previous crap
    $exp->expect(1, $today);  # this is on the inquiry screen
    $exp->expect(1, $today);  # this is on the result screen
    $exp->expect(1, "11=Charge");

    # get the result screen
    $result = $exp->before();

    # kill the connection. soft_close takes several seconds
    $exp->hard_close();

    # the $today and two spaces were stripped, so add them back
    return "  ".$today.$result;
}

main();


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

# vim: ts=4:sts=4:sw=4

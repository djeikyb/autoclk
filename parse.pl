#!/usr/bin/env perl

use warnings;
use strict;

my @lines = <STDIN>;

my $audit_date = substr($lines[0],24,8);
my $audit_time = substr($lines[0],33,8);

foreach my $line (@lines[6..10])
{
    next if ($line =~ /^ *$/);

    my $day = substr($line,5,8);
    my $time_in = substr($line,14,5);
    my $time_out = substr($line,22,5);
    my $hours = substr($line,32,5);
    my $pcd = substr($line,41,8);

    print("$audit_date,$audit_time,$day,$time_in,$time_out,$hours,$pcd\n");
}

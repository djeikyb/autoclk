#!/usr/bin/env perl

use warnings;
use strict;

my @lines = <STDIN>;

my $audit_date = dayTransform(substr($lines[0],16,8));
my $audit_time = substr($lines[0],25,8);

foreach my $line (@lines[6..10])
{
    next if ($line =~ /^ *$/);

    my $day = dayTransform(substr($line,5,8));
    my $time_in = substr($line,14,5);
    my $time_out = substr($line,22,5);
    my $hours = substr($line,31,5);
    my $pcd = substr($line,44,5);

    print("$audit_date,$audit_time,$day,$time_in,$time_out,$hours,$pcd\n");
}

sub dayTransform
{
    my ($day) = @_; # @_ is the array of args passed in
    my @parts = split(/\//,$day);
    $day = "20".$parts[2]."-".$parts[1]."-".$parts[0];
    $day =~ s/ /0/g;
    return $day;
}

# vim: ts=4:sts=4:sw=4

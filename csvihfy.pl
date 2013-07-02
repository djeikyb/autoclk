#!/usr/bin/env perl

use warnings;
use strict;

use POSIX qw/strftime/;

my @lines = <STDIN>;

sub main()
{
    my $timestamp = get_timestamp($lines[0]);
    my $audit_date = dayTransform(substr($timestamp, 0, 8));
    my $audit_time = substr($timestamp, 9, 8);

    my $clkin = "";

    foreach my $line (@lines[6..16])
    {
        next if ($line =~ /^\s*$/);

        my $day = dayTransform(substr($line,6,8));
        my $time_in = substr($line,15,5);
        my $time_out = substr($line,23,5);
        my $hours = substr($line,32,5);
        my $pcd = substr($line,45,5);

        $clkin = $time_in;

        print("$audit_date,$audit_time,$day,$time_in,$time_out,$hours,$pcd\n");
    }
}

sub get_hours_done()
{
    return substr($lines[19],64,8);
}

sub get_timestamp
{
    my ($line) = @_;
    return substr($line, 1, 17);
}

sub dayTransform
{
    my ($day) = @_; # @_ is the array of args passed in
    my @parts = split(/\//,$day);
    $day = "20".$parts[2]."-".$parts[0]."-".$parts[1];
    $day =~ s/ /0/g;
    return $day;
}

main();

# vim: ts=4:sts=4:sw=4

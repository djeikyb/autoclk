#!/usr/bin/env perl

use warnings;
use strict;

while (<>)
{
  s/\e\[?.*?[\@-~]//g;
  s///g;
  print;
}

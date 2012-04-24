#!/usr/bin/perl

use strict;
use FindBin;
use lib "$FindBin::Bin/../tlib";

use WWW::Chargify::Tests::HTTP;


# Run the tests
Test::Class->runtests;

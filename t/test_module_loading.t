#!/usr/bin/perl
use strict;
use Test::More tests => 6;


use_ok("WWW::Chargify");
use_ok("WWW::Chargify::CreditCard");
use_ok("WWW::Chargify::Subscription");
use_ok("WWW::Chargify::Customer");
use_ok("WWW::Chargify::Product");
use_ok("WWW::Chargify::ProductFamily");


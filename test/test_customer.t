#!/usr/bin/perl-completion-mode doesn't use own key-map.


use strict;
use Moose;


use Test::More tests => 4;
my $chargify;
my @products;
my $cust;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

use_ok("WWW::Chargify");
use_ok("WWW::Chargify::Customer");


$chargify = WWW::Chargify->new(  subdomain  => $ENV{SUBDOMAIN},
                                 apiKey     => $ENV{APIKEY}
                             );

#@products = $chargify->product_families();

# Before we get to the Customer, lets
# add the Product


$cust =  $chargify->newCustomer( first_name => 'Joe', last_name => 'Plummer', email => 'joeplummer@pipecleaning.com', reference => 'jplummer' );

$cust->save();

$cust->organization("Joe Plumming");
$cust->address("123 BillingSt.");
$cust->address_2("#3");
$cust->city("San Diego ");
$cust->country("CA");
$cust->phone("8585551212");
$cust->state("CA");
$cust->zip("92104");

$cust->save();


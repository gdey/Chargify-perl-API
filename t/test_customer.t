#!/usr/bin/perl
#-completion-mode doesn't use own key-map.


use strict;
use Moose;
use 5.10.0;

use lib './lib';

use Test::More tests => 4;
use Data::Dumper;
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


my $rand = rand();
print "rand seed is : $rand\n";
#$cust =  $chargify->newCustomer( first_name => 'Joe'.$rand, last_name => 'Plummer', email => 'joeplummer@pipecleaning.com', reference => 'jplummer'.$rand );
#
#$cust->save();
#
#$cust->organization("Joe Plumming");
#$cust->address("123 BillingSt.");
#$cust->address_2("#3");
#$cust->city("San Diego ");
#$cust->country("CA");
#$cust->phone("8585551212");
#$cust->state("CA");
#$cust->zip("92104");
#
## This will update the customer.
#$cust->save();

print "All customers: ".Dumper( WWW::Chargify::Customer->list( http => $chargify->http ) );
print "All customers named foo: ".Dumper( scalar WWW::Chargify::Customer->find_by_query( http => $chargify->http, query => 'foo' ) );
print "All customers named plum: ".Dumper( scalar WWW::Chargify::Customer->find_by_query( http => $chargify->http, query => 'plum' ) );


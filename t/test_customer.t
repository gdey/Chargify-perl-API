#!/usr/bin/perl


use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Test::More tests => 11;
my $chargify;
my @products;
my $cust;

no warnings;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

use_ok("WWW::Chargify");
use_ok("WWW::Chargify::Customer");
use_ok("WWW::Chargify::Product");

open(SAVEOUT, ">&STDOUT");
open(STDOUT, ">/dev/null") || warn "Can't redirect stdout";

my $userid =  "jplummer";

$chargify = WWW::Chargify->new(  
                                 subdomain  => $ENV{SUBDOMAIN},
                                 apiKey     => $ENV{APIKEY}
                             );

ok($chargify, 'Got a good chargify object');

#@products = $chargify->product_families();
# Before we get to the Customer, lets
# add the Product
throws_ok {
   $chargify->newCustomer(
         first_name => 'Joe',
         last_name => 'Plummer',
   );
} qr/Attribute \(email\) is required/, "Email attribute is required";
throws_ok {
   $chargify->newCustomer(
         email => 'joeplummer@pipecleaning.com',
         last_name => 'Plummer',
   );
} qr/Attribute \(first_name\) is required/, "first_name attribute is required";
throws_ok {
   $chargify->newCustomer(
         email => 'joeplummer@pipecleaning.com',
         first_name => 'Plummer',
   );
} qr/Attribute \(last_name\) is required/, "last_name attribute is required";

$cust =  $chargify->newCustomer(
                                email => 'joeplummer@pipecleaning.com',
                                first_name => 'Joe',
                                last_name => 'Plummer',
                               );
ok($cust , "Got a good customer object");

$cust->address("123 BillingSt.");
$cust->address_2("#3");
$cust->city("San Diego ");
$cust->country("CA");
$cust->organization("Joe Plumming");
$cust->phone("8585551212");
$cust->reference( $userid );
$cust->state("CA");
$cust->zip("92104");

throws_ok { 
    $cust->save();
} qr/Reference: must be unique/, "Correctly has issues saving (duplicate)";

#find the user and update its shipping address
$cust = $chargify->find_customer_by_reference( $userid );

my $tmpaddress = $cust->address();
#$DB::signal = 1;
$tmpaddress =~ s/^\s*(\d+)(\s+\S+.*)$/($1+1) . $2/eg;
$cust->address( $tmpaddress );

lives_ok { 
    $cust->reference( $userid );
    $cust->save();
} "Able to save the customer now";
    
#
# Verify that the code is the same
$cust = $chargify->find_customer_by_reference( $userid );
is( $cust->address, $tmpaddress, "Got the modified address");


# Add a subscriptiong to the customer.
# $cust->add_subscription( product => $product );



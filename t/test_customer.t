#!/usr/bin/perl

use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Test::More tests => 12;
my $chargify;
my @products;
my $cust;

no warnings;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

use_ok("WWW::Chargify");
use_ok("WWW::Chargify::Subscription");
use_ok("WWW::Chargify::Customer");
use_ok("WWW::Chargify::Product");

unless ( $ENV{GAUTAM_PLAY} ){

open(SAVEOUT, ">&STDOUT");
open(STDOUT, ">/dev/null") || warn "Can't redirect stdout";

}

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


sub gautam_play {

    print 'Running Gautam\'s games';
    use Data::Dumper;
    my $rand = rand();
    print "rand seed is : $rand\n";
    my $product = WWW::Chargify::Product->find_by_handle( http => $chargify->http, handle => 'foo' );
    #print Dumper($product);
    #$cust =  $chargify->newCustomer( first_name => 'Joe'.$rand, last_name => 'Plummer', email => 'joeplummer@pipecleaning.com', reference => 'jplummer'.$rand );
    #
    #$cust->save();
    #
    ##$cust->organization("Joe Plumming");
    ##$cust->address("123 BillingSt.");
    ##$cust->address_2("#3");
    ##$cust->city("San Diego ");
    ##$cust->country("CA");
    ##$cust->phone("8585551212");
    ##$cust->state("CA");
    ##$cust->zip("92104");
    #
    ## This will update the customer.
    #$cust->save();
    
    # Add a subscription to the customer.
    #print Dumper( $cust->add_subscription( product => $product ) );
    #print Dumper( $cust->add_subscription( 
    #         product => $product, 
    #         creditcard => WWW::Chargify::CreditCard->new(
    #             config => $cust->config,
    #             http   => $cust->http,
    #             full_number      => '4'.'1'x15,
    #             billing_address  => '123 Springfield',
    #             billing_address2 => 'apt #2',
    #             billing_city     => 'San Diego',
    #             billing_state    => 'CA',
    #             billing_zip      => '92116', 
    #             billing_country  => 'US',
    #             cvv              => '123',
    #             expiration_month => '12',
    #             expiration_year  => '2015',
    #             card_type        => 'visa',
    #) ) );

    # Here we are creating a new customer, new creditcard information, and a subscription, all at one time.
    my $cust1 =  $chargify->newCustomer( first_name => 'Joe'.$rand, last_name => 'Plummer', email => 'joeplummer@pipecleaning.com', reference => 'jplummer'.$rand );
    print Dumper( $cust1->add_subscription( 
             product => $product, 
             next_billing_at => DateTime->now->add( days => 10 ),
             coupon_code => 'WHY',
             creditcard => WWW::Chargify::CreditCard->new(
                 config => $cust->config,
                 http   => $cust->http,
                 full_number      => '4'.'1'x15,
                 billing_address  => '123 Springfield',
                 billing_address2 => 'apt #2',
                 billing_city     => 'San Diego',
                 billing_state    => 'CA',
                 billing_zip      => '92116', 
                 billing_country  => 'US',
                 cvv              => '123',
                 expiration_month => '12',
                 expiration_year  => '2015',
                 card_type        => 'visa',
    ) ) );
    #my $cust2 =  $chargify->newCustomer( first_name => 'Joe'.$rand, last_name => 'Plummer', email => 'joeplummer@pipecleaning.com', reference => 'jplummer'.$rand );
    #print Dumper( $cust2->add_subscription( 
    #         product => $product, 
    #         next_billing_at => DateTime->now->add( days => 2 ),
    #         creditcard => WWW::Chargify::CreditCard->new(
    #             config => $cust->config,
    #             http   => $cust->http,
    #             full_number      => '4'.'1'x15,
    #             billing_address  => '123 Springfield',
    #             billing_address2 => 'apt #2',
    #             billing_city     => 'San Diego',
    #             billing_state    => 'CA',
    #             billing_zip      => '92116', 
    #             billing_country  => 'US',
    #             cvv              => '123',
    #             expiration_month => '12',
    #             expiration_year  => '2015',
    #             card_type        => 'visa',
    #) ) );
    print Dumper( $chargify->products );



}
gautam_play if $ENV{GAUTAM_PLAY};


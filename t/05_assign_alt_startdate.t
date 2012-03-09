#!/usr/bin/perl

use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Log::Log4perl;
use List::Util qw(first);
use Time::Local;
use Test::More;
use Date::Manip;
use DateTime::Format::DateManip;
my $chargify;
my @products;
my $cust;

no warnings;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

use_ok("WWW::Chargify");
use_ok("WWW::Chargify::Subscription");
use_ok("WWW::Chargify::Customer");
use_ok("WWW::Chargify::Product");

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  VARIABLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
my $userid =  $ENV{TESTUSER_COMPONENT};
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
  $Log::Log4perl::DEBUG;
my @user_subs;
my @subscriptions = split " ", $ENV{TEST_COMPONENT_SUBSCRIPTIONS};
my $product;
my $account;
my $start_date = $ENV{TEST_START_DATE} ne "" ?  
                 DateTime::Format::DateManip->parse_datetime( ParseDate( $ENV{TEST_START_DATE} )) :  
                 DateTime->now->add( minutes => 3 ) ;
my $sub;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TEST_MIGRATE_USER} );
@products = $chargify->products;

$product = first { $_->handle() eq $ENV{TEST_PRODUCT_CHARGIFY} } @products;

lives_ok {

    print "";
    $sub = $account->add_subscription
                     (
                      product          => $product,
                      next_billing_at  => $start_date,
                      creditcard => WWW::Chargify::CreditCard->new
                      (
                       config           => $chargify->config,
                       billing_address  => "123 Billing St",
                       billing_address2 => "#2",
                       billing_city     => "San Diego",
                       billing_country  => "US",
                       billing_state    => "CA",
                       billing_zip      => "92104",
                       cvv              => "123",
                       expiration_month => "09",
                       expiration_year  => DateTime->now->year + 1,
                       full_number      => "4111111111111111"
                      ), 
                     );
    $sub = first { $_->state eq "active" } $account->subscriptions;
    print "";
} , sprintf("Able to create a subscription for user %s, and product %s, and startdate %s",
            $account->reference,
            $product->handle,
            $sub->next_billing_at,
           );

print "";


done_testing();

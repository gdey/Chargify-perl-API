#!/usr/bin/perl

use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Log::Log4perl;
use List::Util qw(first);
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
my $prod;
my $account;
my @components;
my $usage = defined $ENV{TEST_MIGRATE_USAGE_AMOUNT} && $ENV{TEST_MIGRATE_USAGE_AMOUNT} =~ /^\d+$/ ? 
            $ENV{TEST_MIGRATE_USAGE_AMOUNT} : 
            5000 ;
my $sub;
my $regex;
my $component;
my $cc;
my $product;
my $start_date = $ENV{TEST_START_DATE} ne "" ?  
                 DateTime::Format::DateManip->parse_datetime( ParseDate( $ENV{TEST_START_DATE} )) :  
                 DateTime->now->add( minutes => 3 ) ;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TEST_MIGRATE_USER} );
lives_ok {

    #
    # We just use some old CC number , doens't matter for this test    
    #
    $cc   = (first {1}  $account->subscriptions)->credit_card;
    $product = first { $_->handle eq $ENV{TEST_MIGRATE_USAGE_PRODUCT}}  $chargify->products;
    print "USING  $start_date";
    $account->add_subscription
              (
               product            => $product,
               next_billing_at    => $start_date,
               creditcard         => $cc, 
              );
} ,"Able to assign a product correctly";


done_testing();

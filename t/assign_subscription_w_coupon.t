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

BEGIN{
  use Test::More;
  use Test::Exception;

  unless( $ENV{CHARGIFY_SUBDOMAIN} && 
        $ENV{CHARGIFY_APIKEY}
      ){
     note("NEEDED VARIABLES NOT DEFINED. THIS DOES NOT CHECK FOR ALL VARIABLES, THIS NEEDS TO BE FIX. SKIPPING FOR NOW. PLEASE look at the source for the correct ENV VARIABLES");
     plan skip_all => "Can not run tests without Chargify information.";

  }
  use_ok("WWW::Chargify");
  use_ok("WWW::Chargify::Subscription");
  use_ok("WWW::Chargify::Customer");
  use_ok("WWW::Chargify::Product");
  use_ok("WWW::Chargify::Coupon");
}

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
my @coupons;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TEST_MIGRATE_USER} );

#
# Cancel the subscriptions first
#
foreach my $sub ( $account->active_subscriptions ) {
  $sub->cancel();
}

lives_ok {

    $product = first { $_->handle eq $ENV{TEST_PRODUCT_CHARGIFY} } WWW::Chargify::Product->list( http => $chargify->http );

    @coupons = $product->product_family->active_coupons;
    #
    # We just use some old CC number , doesn't matter for this test    
    #
    $cc   = (first {1}  $account->subscriptions)->credit_card;

    $sub = $account->add_subscription
                     (
                      product            => $product,
                      next_billing_at    => $start_date,
                      creditcard         => $cc, 
                      coupon_code        => $coupons[int(rand(@coupons))]->code,
                     );
    print "";
} ,"Able to assign a product correctly";


done_testing();

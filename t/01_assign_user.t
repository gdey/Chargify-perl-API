#!/usr/bin/perl

use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Log::Log4perl;
use List::MoreUtils;
use Test::More;
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
}

sub chargify {
   state $chargify = WWW::Chargify->new(
      subdomain => $ENV{CHARGIFY_SUBDOMAIN} || $ENV{SUBDOMAIN},
      apiKey => $ENV{CHARGIFY_APIKEY} || $ENV{APIKEY},
   );
   return $chargify;
}


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  VARIABLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

my $userid =  $ENV{TESTUSER_COMPONENT};
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
  $Log::Log4perl::DEBUG;
my @user_subs;
my @subscriptions = split " ", $ENV{TEST_COMPONENT_SUBSCRIPTIONS};
my $prod;
my $account;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_COMPONENT} );
@user_subs  = grep { $_->state eq "active" } $account->subscriptions;

foreach my $i ( @subscriptions[0..0] ) {
    last if $i eq "";
    $prod = WWW::Chargify::Product->find_by
            ( $chargify->http, 
              handle => $i
            );
    next unless $prod;
    next if grep { $prod->id == $_->product->id } @user_subs;
    next if grep { $prod->product_family->id == $_->product->product_family->id } @user_subs;
    lives_ok { 
    $account->add_subscription
              (
               product         => $prod,
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
    print "";
   } "Able to add new subscription of type '" . $prod->name . "' and id '" . $prod->id . "'";
}

#
# First assign the plans that we want
#



done_testing();

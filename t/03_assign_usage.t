#!/usr/bin/perl

use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Log::Log4perl;
use List::Util qw(first);
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

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  VARIABLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

my $userid =  $ENV{TESTUSER_COMPONENT};
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
  $Log::Log4perl::DEBUG;
my @user_subs;
my @subscriptions = split " ", $ENV{TEST_COMPONENT_SUBSCRIPTIONS};
my $prod;
my $account;
my @components;
my $usage;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_COMPONENT} );


my @subs = grep { $_->state eq "active" } $account->subscriptions;

@components = first { $_->name =~ /$ENV{TEST_COMPONENT_PATTERN}/i  } $subs[0]->components;


$usage = $subs[0]->usage_for_component( component => $components[0] );

#$DB::signal = 1;
lives_ok {
$subs[0]->add_usage_for_component
          ( 
           component => $components[0],
           quantity  => 4000,
           memo      => "Added on " . DateTime->now(),
          );
} "Able to add positive usage";

lives_ok {
$subs[0]->add_usage_for_component
          ( 
           component => $components[0],
           quantity  => -4000,
           memo      => "Added on " . DateTime->now(),
          );
} "Able to add negative usage";

done_testing();

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
my $prod;
my $account;
my @components;
my $usage = defined $ENV{TEST_MIGRATE_USAGE_AMOUNT} && $ENV{TEST_MIGRATE_USAGE_AMOUNT} =~ /^\d+$/ ? 
            $ENV{TEST_MIGRATE_USAGE_AMOUNT} : 
            5000 ;
my $sub;
my $regex;
my $component;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TEST_MIGRATE_USER} );


$sub         = first { $_->state eq "active" } $account->subscriptions;
$prod        = $sub->product;
($regex      = $sub->product->name) =~ s/^(.*)\(.*$/$1/;
$regex       = qr{$regex}i;
$component   = first { $_->name =~ $regex } $sub->components;

#$DB::signal = 1;
lives_ok {
$sub->add_usage_for_component
      ( 
       component => $component,
       quantity  => $usage,
       memo      => "Added on " . DateTime->now(),
      );
} "Able to add usage";


done_testing();

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

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  GLOBALS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

my $chargify;
my @products;
my $cust;
my $prod;
my $sub;
my $account;
my @other_prods;
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
  $Log::Log4perl::DEBUG;


no warnings;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

use_ok("WWW::Chargify");
use_ok("WWW::Chargify::Subscription");
use_ok("WWW::Chargify::Customer");
use_ok("WWW::Chargify::Product");
use_ok("WWW::Chargify::Migration");



$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TEST_MIGRATE_USER2} );

$sub = first { $_->state eq "active" } $account->subscriptions ;


$prod =  $sub->product;

@other_prods = grep { $_->handle ne $prod->handle }  $sub->product->product_family->products ;

#
# We will migrate to each of the other products and 
# then back to the original product
#
lives_ok { 
    foreach my $i ( @other_prods ) {
        my $migration = WWW::Chargify::Migration->new( 
                                                      product_handle => $i->handle,
                                                      include_trial  => 0,
                                                      include_initial_charge => 0
                                                     );
        $sub->add_migration( migration => $migration );
        print "";
        
    }
} "Able to migrate to other products correctly";

lives_ok {
    my $migration = WWW::Chargify::Migration->new( 
                                                  product_handle => $prod->handle,
                                                  include_trial  => 0,
                                                  include_initial_charge => 0
                                                 );
    $sub->add_migration( migration => $migration );
    
} "Able to migrate back to the original product";


done_testing()





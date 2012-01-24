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
my @prods;
my $prod;
my $account;
my ($orig,$changed);
my $tmp;
my $newcc;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_COMPONENT} );

@user_subs = grep { $_->state eq "active" } $account->subscriptions;
$orig = $user_subs[0]->product->id ;
if ( 1 ) { 
lives_ok {
      @prods = grep { $_->id != $orig } $user_subs[0]->product->product_family->products;
} "Able to find the orginal product id: '$orig'";

#
# Randomly select a new product
#
$user_subs[0]->product( $prods[int rand(@prods)]  );
$changed = $user_subs[0]->product->id;

lives_ok { 
    $user_subs[0]->save;
} "Able to perform initial save with id '$changed'";

@user_subs = grep { $_->state eq "active" } $account->subscriptions;
is( $user_subs[0]->product->id , $changed, "Product ID was updated to '$changed'");

lives_ok { 
    @prods = grep { $_->id == $orig } $user_subs[0]->product->product_family->products;
    $user_subs[0]->product( $prods[0] );
    $user_subs[0]->save;
} "Able to find the original product id: '$orig'";

lives_ok {
    @user_subs = grep { $_->state eq "active" } $account->subscriptions;
} "Able to get the new subscriptions";

is( $user_subs[0]->product->id , $orig, "Able to set back to the original Product '$orig'");
}
#
# Try a situation where the user adds a new CC number
lives_ok  {
    $newcc = $user_subs[0]->credit_card;
    ($tmp = $newcc->billing_address) =~ s/^(\d+)(\s+.*)$/($1 + 1) . $2/eg;
    $newcc->billing_address( $tmp );
    delete $newcc->{id};
    $newcc->full_number( $ENV{TEST_CC_NUMBER} );
    
    $user_subs[0]->credit_card( $newcc );
    $user_subs[0]->save;
} "Able to update the Credit Card information";

print "";



done_testing();

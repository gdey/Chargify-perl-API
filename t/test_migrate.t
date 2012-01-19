#!/usr/bin/perl
#
#
#
#


use strict;
use WWW::Chargify;
use WWW::Chargify::Subscription;
use WWW::Chargify::Customer;
use Test::More ;
use Test::Exception;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  VARS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

my $chargify;
my $account;
my @subscriptions;
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
               $Log::Log4perl::DEBUG;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new
            ( 
             subdomain => $ENV{SUBDOMAIN},
             apiKey    => $ENV{APIKEY},
            );
$chargify->logger->level( $loglevel );
$chargify->logger->debug("Something");

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_MIGRATE} );

$chargify->products();


@subscriptions = grep { $_->state eq "active" } $account->subscriptions;

#
# Going to upgraade each plan
#

foreach my $sub ( @subscriptions ) {
    my @alt = grep { $_->id != $sub->product->id }  
              $sub->product->product_family->products ;

    next if $#alt < 0;
    # Iterate moving over each product
    lives_ok { 
        $sub->migrate( to_product => $alt[0], include_trial => 0  );
    } "Able to migrate product '" . $sub->product->name . "' to '" . $alt[0]->name . "'";
}



#
#
#
done_testing();


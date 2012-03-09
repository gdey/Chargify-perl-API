#!/usr/bin/perl

use strict;
use Moose;
use Test::Exception;
use Date::Format;
use Log::Log4perl;
use List::MoreUtils;
use List::Util qw(first);
use Test::More;
use UNIVERSAL;
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
my $sub;
my $chargify;
my $account;
my @subs;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_COMPONENT} );

isa_ok($account,"WWW::Chargify::Customer", "Found a valid customer");

lives_ok {
    @subs = $account->subscriptions;

} "Able to get the subscriptions";

is( (scalar @subs) >= 1, 1 , "At least one subscription exists");

$sub = first { UNIVERSAL::can($_,"state") && $_->state eq "active" } @subs;
if( ! $sub ) {
    my $cc      = (first {1}  $account->subscriptions)->credit_card;
    my $product = first { $_->handle eq $ENV{TEST_MIGRATE_USAGE_PRODUCT}}  $chargify->products;
    eval { 
    $account->add_subscription( 
                               product            => $product,
                               creditcard         => $cc, 
                              );
    };
    if( $@ =~ /Customer Profile ID or Customer Payment Profile ID not found/) {
        $account->add_subscription( 
                                   product            => $product,
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
    }
}



$sub->credit_card->billing_address2("Foo street");
delete $sub->{id};

eval {
    $sub->save();
};

print "";

done_testing();

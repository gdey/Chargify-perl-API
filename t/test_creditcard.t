#!/usr/bin/perl
#-completion-mode doesn't use own key-map.

use strict;
use Moose;
use 5.10.0;
use lib './lib';

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  GLOBALS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

my $chargify;
my @products;
my $cc;
my $cust;
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || $Log::Log4perl::DEBUG;
my $product;
my $rand;   
my $reference;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

BEGIN {
  use Test::More;
  use Test::Exception;
  use Data::Dumper;
  use Log::Log4perl;
  no warnings;
  unless( $ENV{CHARGIFY_SUBDOMAIN} && 
        $ENV{CHARGIFY_APIKEY}
      ){
     note("NEEDED VARIABLES NOT DEFINED. THIS DOES NOT CHECK FOR ALL VARIABLES, THIS NEEDS TO BE FIX. SKIPPING FOR NOW. PLEASE look at the source for the correct ENV VARIABLES");
     plan skip_all => "Can not run tests without Chargify information.";

  }
  use_ok("WWW::Chargify");
  use_ok("WWW::Chargify::CreditCard");
  use_ok("WWW::Chargify::Subscription");
  use_ok("WWW::Chargify::Customer");
  use_ok("WWW::Chargify::Product");
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub debug_print($);

use_ok("WWW::Chargify::CreditCard");


$chargify = WWW::Chargify->new(  subdomain  => $ENV{CHARGIFY_SUBDOMAIN2},
                                 apiKey     => $ENV{CHARGIFY_APIKEY}
                             );
$chargify->logger->level( $loglevel );



# Before we get to the Customer, lets
# add the Product


$reference = $ENV{TEST_USER_ADD_SUBSCRIPTION};
$chargify->logger->debug( "rand seed is : $rand\n" );

$product = WWW::Chargify::Product->find_by_handle( http => $chargify->http, handle => $ENV{'TEST_COMPONENT_ORIGINAL'} );
$chargify->logger->debug(  Dumper($product) );


$cust = $chargify->find_customer_by_reference( $reference ) || $chargify->newCustomer
                                                                          ( first_name => 'Joe',                                 
                                                                            last_name => 'Plummer', 
                                                                            email => 'joeplummer@pipecleaning.com', 
                                                                            reference => $reference 
                                                                          );

lives_ok { 
    $cust->save();
} "Able to save the Customer";

$cust->organization("Joe Plumming");
$cust->address("123 BillingSt.");
$cust->address_2("#3");
$cust->city("San Diego ");
$cust->country("CA");
$cust->phone("8585551212");
$cust->state("CA");
$cust->zip("92104");

#
# Save the CC information for the user
#
print "";
$cc = WWW::Chargify::CreditCard->new(
                                     full_number      => "4111111111111111",
                                     expiration_month => "11",
                                     expiration_year  => "2013",
                                     cvv              => "123",
                                     billing_address  => "123 Billing St.",
                                     billing_city     => "Folsom",
                                     billing_state    => "CA",
                                     billing_zip      => "95630",
                                    );

# This will update the customer.
lives_ok { 
    $cust->save();
} "Updating the customer and then saving again";

lives_ok { 
    $cust->add_subscription( product => $product , creditcard => $cc  );
} "Able to add a subscription to a product";

done_testing();

sub debug_print($)
{
    my $tmp;
    print @_ if( defined ($tmp = $ENV{DEBUG_PRINT} ) ); 
}

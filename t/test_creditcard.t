#!/usr/bin/perl
#-completion-mode doesn't use own key-map.

use strict;
use Moose;
use 5.10.0;

use lib './lib';

use Test::More tests => 4;
use Test::Exception;
use Data::Dumper;
use Log::Log4perl;
no warnings;
my $chargify;
my @products;
my $cust;
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || $Log::Log4perl::DEBUG;


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
sub debug_print($);

use_ok("WWW::Chargify::CreditCard");


$chargify = WWW::Chargify->new(  subdomain  => $ENV{SUBDOMAIN2},
                                 apiKey     => $ENV{APIKEY}
                             );
$chargify->logger->level( $loglevel );


#@products = $chargify->product_families();

# Before we get to the Customer, lets
# add the Product


my $rand = rand();
debug_print "rand seed is : $rand\n";
my $product = WWW::Chargify::Product->find_by_handle( http => $chargify->http, handle => 'foo' );
debug_print Dumper($product);
$cust =  $chargify->newCustomer( first_name => 'Joe'.$rand, last_name => 'Plummer', email => 'joeplummer@pipecleaning.com', reference => 'jplummer'.$rand );

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

# This will update the customer.
lives_ok { 
    $cust->save();
} "Updating the customer and then saving again";

lives_ok { 
    $cust->add_subscription( product => $product );
} "Able to add a subscription to a product";

#print "All customers: ".Dumper( WWW::Chargify::Customer->list( http => $chargify->http ) );
#print "All customers named foo: ".Dumper( scalar WWW::Chargify::Customer->find_by_query( http => $chargify->http, query => 'foo' ) );
#print "All customers named plum: ".Dumper( scalar WWW::Chargify::Customer->find_by_query( http => $chargify->http, query => 'plum' ) );


sub debug_print($)
{
    my $tmp;
    print @_ if( defined ($tmp = $ENV{DEBUG_PRINT} ) ); 
}

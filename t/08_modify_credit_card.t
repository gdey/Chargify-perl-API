#!/usr/bin/perl
#

BEGIN{
  use Test::More;
  use Test::Exception;
  use strict;
  use Data::Dumper qw(Dumper);
  use List::Util qw(/\S+/);
  use DateTime;
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
my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
  $Log::Log4perl::DEBUG;

my $chargify;
my $sub;
my $cc;
my $naddress;
#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=


$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_COMPONENT} );
$sub     = first {1}$account->active_subscriptions;

#
# Changing to a random month not currently on the existing card
#
($naddress = $sub->credit_card->billing_address ) =~ s/(^\d+)(\s+.*)/($1+int(rand(300))) . $2 /eg;

$cc      = WWW::Chargify::CreditCard->new
           (
            config           => $chargify->config,
            billing_address  => $naddress, 
            billing_address2 => "#2",
            billing_city     => "San Diego",
            billing_country  => "US",
            billing_state    => "CA",
            billing_zip      => "92114",
            cvv              => "123",
            expiration_month => ( first { 1 } shuffle grep {$_ != $sub->credit_card->expiration_month } (1..12) ),
            expiration_year  => DateTime->now->year + 1,
            full_number      => "4222222222222"
           );

#%$sub->credit_card( $cc );
lives_ok { 
    $sub->update_creditcard( credit_card => $cc );
} "Able to update credit card correctly";

if( $@) { 
    my $errors = $@->errors;
    print "\n\n" . Dumper($errors) . "\n";
}
done_testing();


#!/usr/bin/perl

use 5.10.0;
use feature 'state';
use strict;
use warnings;
use List::Util qw(first);

BEGIN{
use Test::More;
use Test::Exception;

unless( $ENV{CHARGIFY_SUBDOMAIN} && 
        $ENV{CHARGIFY_APIKEY}    &&
        $ENV{CHARGIFY_TESTUSER}  &&
        $ENV{CHARGIFY_TESTSUBID}
      ){
  note("We need the CHARGIFY_SUBDOMAIN, CHARGIFY_APIKEY, CHARGIFY_TESTUSER, and CHARGIFY_TESTSUBID Environmental variables to be set.");
  plan skip_all => "Can not run tests without Chargify information.";

  }
  use_ok("WWW::Chargify");
  use_ok("WWW::Chargify::Subscription");
}

sub chargify {
   state $chargify = WWW::Chargify->new(
      subdomain => $ENV{CHARGIFY_SUBDOMAIN},
      apiKey => $ENV{CHARGIFY_APIKEY},
   );
   return $chargify;
}

sub test_cancel_at_end_subscription {

   my $account = chargify->find_customer_by_reference( $ENV{CHARGIFY_TESTUSER} );
   my $sub = first {$_->state eq "active" } $account->subscriptions;
   ok($sub,"Found subscription");
   plan skip_all => "Subscription[ $ENV{CHARGIFY_TESTSUBID} ] for given user $ENV{CHARGIFY_TESTUSER}" unless $sub;

   plan skip_all => "Subscription[ $ENV{CHARGIFY_TESTSUBID} ] is not an active subscription." unless $sub->state eq 'active';
   ok($sub->cancel_at_end_of_period == !!0,"Cancel at end of period is not set.");

   lives_ok(sub { $sub->cancel_at_end_of_period(1) }, "Cancel at the end of period");
   lives_ok(sub{  $sub->save },"Save the subscription.");

   my $sub_after = first { $_->id == $ENV{CHARGIFY_TESTSUBID} } $account->subscriptions;

   ok($sub, "sub found sub again");
   note("State is ".$sub->state);
   ok($sub->state eq 'active', "Sub is not active");
   ok($sub->cancel_at_end_of_period,"Cancel at end of period is set.");
   my $ddate = $sub->delayed_cancel_at;
   ok($ddate,"We have a delayed cancel.");
   isa_ok($ddate, 'DateTime', "it's a date time object.");

   note("Time to reactivate it.");
   lives_ok(sub { $sub->cancel_at_end_of_period(0) }, "Reactivate a Canceled at the end of period");
   lives_ok(sub{  $sub->save },"Save the subscription.");

}

test_cancel_at_end_subscription;

done_testing();

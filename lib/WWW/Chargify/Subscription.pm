package WWW::Chargify::Subscription;
use Moose;
use MooseX::Method::Signatures;

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';

has id => ( is => 'ro', isa => 'Num');
has state => ( is => 'ro', isa => 'Str');
has balance_in_cents => ( is => 'ro', isa => 'Num');
has current_period_started_at => ( is => 'ro', isa => 'DateTime' );
has current_period_ends_at => (is => 'ro', isa => 'DateTime' );
has next_assessment_at => ( is => 'ro', isa => 'DateTime' );
has trial_started_at => ( is  => 'ro', isa => 'DateTime' );
has trial_ended_at => ( is => 'ro', isa => 'Datetime' );
has activated_at => ( is => 'ro', isa => 'DateTime' );
has expires_at => (is => 'ro', isa => 'DateTime' );
has created_at => (is => 'ro', isa => 'DateTime' );
has updated_at => (is => 'ro', isa => 'DateTime' );
has customer => ( is => 'ro', isa => 'WWW::Chargify::Customer' );
has product => ( is => 'ro' , isa => 'WWW::Chargify::Product' );
has credit_card => ( is => 'ro', isa => 'WWW::Chargify::CreditCard' );
has cancellation_message => ( is => 'ro', isa => 'Str' );
has canceled_at  => ( is => 'ro', isa => 'DateTime' );
has signup_revenue => ( is => 'ro', isa => 'Num' );
has signup_payment_id => ( is => 'ro', isa => 'Num' );
has cancel_at_end_of_period => ( is => 'ro', isa => 'Bool' );
has delayed_cancel_at  =>  ( is => 'ro', isa => 'DateTime' );
has previos_state => ( is  => 'ro', isa  => 'Str' );
has coupon_code => ( is  => 'ro', isa => 'Str' );


sub list  {
  
   my ($class, $http) = @_;
   my ($subscriptions_json, $response) = $http->get('subscriptions');
   use Data::Dumper;
   say Dumper($subscriptions_json);

}

sub create {
  my ($class, %args ) = @_;

}

method find_by_id( Num $id ){
   my ($subscriptions_json, $response) = $http->get(subscriptions => $id);
   say Dumper($subscription_json);
   
}



1;

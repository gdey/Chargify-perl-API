use Modern::Perl;
use MooseX::Declare;
use WWW::Chargify::CreditCard;
use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;

class WWW::Chargify::Subscription {

   use DateTime;
   use Data::Dumper;
   
   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   with 'WWW::Chargify::Role::List'; 
   with 'WWW::Chargify::Role::Find';
   
   has id => ( is => 'ro', isa => 'Num', traits => [qw[Chargify::APIAttribute]]);
   has state => ( is => 'ro', isa => 'Str', traits => [qw[Chargify::APIAttribute]] );
   has balance_in_cents => ( is => 'ro', isa => 'Num');
   has current_period_started_at => ( 
              is => 'ro', 
              isa => 'DateTime',
              coerce => 1,
   );
   has current_period_ends_at => (
              is => 'ro', 
              isa => 'DateTime',
              coerce => 1,
   );
   has next_assessment_at => ( 
              is => 'ro', 
              isa => 'DateTime',
              coerce => 1,
   );
   has trial_started_at => ( is  => 'ro', isa => 'DateTime', coerce => 1, );
   has trial_ended_at => ( is => 'ro', isa => 'DateTime', coerce => 1, );
   has activated_at => ( is => 'ro', isa => 'DateTime', coerce => 1, );
   has expires_at => (is => 'ro', isa => 'DateTime', coerce => 1, );
   has created_at => (is => 'ro', isa => 'DateTime', coerce => 1, );
   has updated_at => (is => 'ro', isa => 'DateTime', coerce => 1, );
   has canceled_at  => ( is => 'ro', isa => 'DateTime', coerce => 1, );
   has delayed_cancel_at         =>  ( is => 'ro', isa => 'DateTime', coerce => 1, );
   has customer => ( is => 'ro', isa => 'WWW::Chargify::Customer' );
   has product => ( is => 'ro' , isa => 'WWW::Chargify::Product' );
   has credit_card => ( is => 'ro', isa => 'WWW::Chargify::CreditCard' );
   has cancellation_message => ( is => 'ro', isa => 'Str' );
   has signup_revenue => ( is => 'ro', isa => 'Num' );
   has signup_payment_id => ( is => 'ro', isa => 'Num' );
   has cancel_at_end_of_period   => ( is => 'ro', isa => 'Bool' );
   has previos_state             => ( is  => 'ro', isa  => 'Str' );
   has coupon_code               => ( is  => 'ro', isa => 'Str' );
   
   sub _hash_key     { 'subscription' };
   sub _resource_key { 'subscriptions' };
   
   around _from_hash( $class: WWW::Chargify::Config :$config, 
                       WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){

       my $customer_hash = $hash->{ WWW::Chargify::Customer->_hash_key };
       my $customer = WWW::Chargify::Customer->_from_hash( config => $config, http => $http, hash => $customer_hash );
       $hash->{ WWW::Chargify::Customer->_hash_key } = $customer;

       my $product = WWW::Chargify::Product->_from_hash(
             config => $config, 
             http => $http, 
             hash => $hash->{ WWW::Chargify::Product->_hash_key }
       );
       $hash->{ WWW::Chargify::Product->_hash_key } = $product;

       if( exists  $hash->{ WWW::Chargify::CreditCard->_hash_key } and 
           defined $hash->{ WWW::Chargify::CreditCard->_hash_key } ){

          my $credit_card_hash = $hash->{ WWW::Chargify::CreditCard->_hash_key };
          say 'Removing credit card date: '.Dumper($credit_card_hash);
          my $credit_card = WWW::Chargify::CreditCard->_from_hash(
               config => $config, 
                 http => $http, 
                 hash => $credit_card_hash);
          $hash->{ WWW::Chargify::CreditCard->_hash_key } = $credit_card;
       }

       return $orig->($class, config => $config, http => $http, hash => $hash, overrides => $overrides);
       
   }
   
   method transactions {
   
       my $id = $self->id;
       my $config = $self->config;
       my $http = $self->http;
       my $hash_key = WWW::Chargify::Transaction->_hash_key;
       my $resource_key = $self->_resource_key;
       my $transaction_resource_key = WWW::Chargify::Transaction->_resource_key;
   
       my ($objects, $response) = $http->get($resource_key,$id,$transaction_resource_key);
       return map { WWW::Chargify::Transaction->_from_hash( config => $config, http => $http, hash => $_->{$hash_key} ) }
         @{$objects};
   
   
   }
   
   method components {
   
      my $id = $self->id;
      my $config = $self->config;
      my $http = $self->http;
      my $resource_key = $self->_resource_key;
      my $component_hash_key = WWW::Chargify::Component->_hash_key;
      my $component_resource_key = WWW::Chargify::Component->_resource_key;
   
      my ($objects, $response) = $http->get($resource_key,$id,$component_resource_key);
      return map { WWW::Chargify::Transaction->_from_hash( 
         config => $config, 
           http => $http,
           hash => $_{$component_hash_key } 
      ) } @{$objects};
   
   }

   method component_by_id(Num $component_id) {

      my $id = $self->id;
      my $config = $self->config;
      my $http = $self->http;
      my $resource_key = $self->_resource_key;
      my $component_hash_key = WWW::Chargify::Component->_hash_key;
      my $component_resource_key = WWW::Chargify::Component->_resource_key;
      my ($object, $response) = $http->get($resource_key,$id,$component_resource_key,$component_id);
      return WWW::Chargify::Transaction->_from_hash( 
           config => $config, 
             http => $http, 
             hash => $object->{$component_hash_key } ) ;

   }



}

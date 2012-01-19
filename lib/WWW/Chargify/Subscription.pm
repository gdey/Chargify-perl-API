package WWW::Chargify::Subscription;
use Moose;
use DateTime;
use Data::Dumper;

use WWW::Chargify::CreditCard;
use WWW::Chargify::Customer;
use WWW::Chargify::Product;
use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;

   
   
   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   with 'WWW::Chargify::Role::Find';
   with 'WWW::Chargify::Role::List'; 

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
   
   #around _from_hash( $class: WWW::Chargify::Config :$config, 
   #                    WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){
   around _from_hash => sub {

       my ($orig, $class, %args) = @_;
       
       my $http = $args{http}; 
       my $config = $args{config};
       my $hash = $args{hash};
       my $overrides = $args{overrides} || {};

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
          my $credit_card = WWW::Chargify::CreditCard->_from_hash(
               config => $config, 
                 http => $http, 
                 hash => $credit_card_hash);
          $hash->{ WWW::Chargify::CreditCard->_hash_key } = $credit_card;
       }

       return $orig->($class, config => $config, http => $http, hash => $hash, overrides => $overrides);
       
   };
   
   #method transactions {
   sub transactions {

       my $self = shift;
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
   
   #method components {
   sub components {
      my $self = shift;
   
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

   #method component_by_id(Num $component_id) {
   sub component_by_id{
      my ($self, %args) = @_;
      my $component_id = $args{component_id} || "component_id is required.";


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

   #method add_subscription( $class: 

   #      WWW::Chargify::HTTP :$http,
   #      WWW::Chargify::Customer :$customer,
   #      WWW::Chargify::Product :$product,
   #      WWW::Chargify::CreditCard :$creditcard?,
   #      Str :$coupon_code?,
   #      DateTime :$next_billing_at?,
   #      Str :$vat_number? 
   #){ 
   sub add_subscription {
       my ($class, %args)  = @_;

       my $http = $args{http} || confess "http is required.";
       my $customer = $args{customer}  || confess "customer is required.";
       my $product = $args{product} || confess "product is required. ";
       my $creditcard = $args{creditcard};
       my $coupon_code = $args{coupon_code};
       my $next_billing_at = $args{next_billing_at};
       my $vat_number = $args{vat_number};

       # We are going to be creating a new subscription for a customer.
       # Now a customer could be new, in which case, we need to get hash for the customer, 
       #   otherwise we need to use the customer->reference, failing that the customer->id.
       
       my %hash = ();
       
       $hash{ product_handle } = $product->handle;

       if ($customer->has_id) {
         # So we have a customer that already exists in the system! Yay.
         warn "Customer reference: ".$customer->reference;
         warn "Customer id: ".$customer->id;
         $customer->has_reference ?
             ( $hash{customer_reference} = $customer->reference )
           : ( $hash{customer_id} = $customer->id );
       } else {
         $hash{ customer_attributes } = $customer->_to_hash_for_new_update;
       }

       if( $creditcard ){
          if( $creditcard->has_id ){
             $hash{ payment_profile_id } = $creditcard->payment_profile_id;
          } else {
             $hash{ payment_profile_attributes } = $creditcard->_to_hash_for_new_update;
          }
       }

       $hash{ coupon_code } = $coupon_code if( $coupon_code );
       $hash{next_billing_at} = DateTime::Format::W3CDTF->new->format_datetime($next_billing_at) if $next_billing_at ;
       $hash{vat_number} = $vat_number if $vat_number;

       my ($object, $response) = $http->post ( $class->_resource_key,  { $class->_hash_key => \%hash } );
       my $config = $http->config;
       return $class->_from_hash( http => $http, config => $config, hash => $object->{$class->_hash_key} );
   }

   #method migrate ( WWW::Chargify::Product :$to_product,
   #   Bool :$include_trial=0,
   #   Bool :$include_initial_charge=0,
   #   Bool :$preview=0
   #){
   sub migrate {
      my ($self, %args) = @_;

      my $to_product = $args{to_product} || confess "to_product is required.";
      my $include_trial  = $args{include_trial} || 0;
      my $include_initial_charge = $args{include_initial_charge} || 0;
      my $preview = $args{preview}  || 0;

      my $http = $self->http;
      my $hash = {
            product_handle => $to_product->handle,
            include_trial => $include_trial,
            include_initial_charge => $include_initial_charge
      };

      if( $preview ){
         my ($object, $response) = $http->post( $self->_resource_key, $self->id, migrations => 'preview.json', $hash );
         return $object;  
      }

      my ($object, $response) = $http->post( $self->_resource_key, $self->id, migrations => $hash );
      return $self->_from_hash( http => $http, config => $http->config, hash => $object->{$self->_hash_key} );  

   }
1;

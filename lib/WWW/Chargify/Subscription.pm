package WWW::Chargify::Subscription;
use Moose;
use MooseX::Params::Validate;
use DateTime;
use Data::Dumper;

use WWW::Chargify::CreditCard;
use WWW::Chargify::Customer;
use WWW::Chargify::Component;
use WWW::Chargify::Product;
use WWW::Chargify::Transaction;
use WWW::Chargify::Usage;
use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
use WWW::Chargify::Migration;
   

   has id                        => ( is => 'ro', isa => 'Num', 
                                      traits => [qw[Chargify::APIAttribute]] , 
                                      predicate => 'has_id'
                                    );
   has state                     => ( is => 'rw', 
                                      isa => 'Str', 
                                      traits => [qw[Chargify::APIAttribute]] 
                                    );
   has balance_in_cents          => ( is => 'ro', 
                                      isa => 'Num'
                                    );

   has current_period_started_at => ( 
                                     is => 'rw', 
                                     isa => 'DateTime',
                                     coerce => 1,
                                    );
   has current_period_ends_at => (
                                  is => 'rw', 
                                  isa => 'DateTime',
                                  coerce => 1,
                                 );
   has next_assessment_at => ( 
                              is => 'ro', 
                              isa => 'DateTime',
                              coerce => 1,
                             );

   has trial_started_at        => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has trial_ended_at          => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has activated_at            => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has expires_at              => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has created_at              => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has updated_at              => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has canceled_at             => ( is => 'rw', isa => 'DateTime', coerce => 1, );
   has delayed_cancel_at       => ( is => 'rw', isa => 'DateTime', coerce => 1, 
                                    predicate => 'has_delayed_cancel_at',
                                    traits         => [qw/Chargify::APIAttribute/],
                                    isAPIUpdatable => 0,
                                  );

   has customer                => ( is => 'rw', 
                                    isa => 'WWW::Chargify::Customer' , 
                                  );

   has product                 => ( is     => 'rw', 
                                    isa    => 'WWW::Chargify::Product|Int'  , 
                                    # traits         => [qw/Chargify::APIAttribute/],
                                    # isAPIUpdatable => 1,
                                  );



   has credit_card             => ( is => 'rw', isa => 'WWW::Chargify::CreditCard', predicate => 'has_credit_card' );
   has cancellation_message    => ( is => 'rw', isa => 'Str'  );
   has signup_revenue          => ( is => 'rw', isa => 'Num'  );
   has signup_payment_id       => ( is => 'rw', isa => 'Num'  );
   has previous_state          => ( is => 'rw', isa => 'Str'  );
   has coupon_code             => ( is => 'rw', isa => 'Str'  );
   has vault_token             => ( is => 'rw', 
                                    isa => 'Str'  ,  
                                    traits => [qw/Chargify::APIAttribute/] , 
                                    isAPIUpdatable => 1
                                  );
   has customer_vault_token    => ( is             => 'rw', 
                                    isa            => 'Int' , 
                                    traits         => [qw/Chargify::APIAttribute/],
                                    isAPIUpdatable => 1,
                                  );
   has customer_id             => ( is             => 'rw', 
                                    isa            => 'Int' , 
                                    traits         => [qw/Chargify::APIAttribute/],
                                    isAPIUpdatable => 1,
                                  );
   has credit_card_attributes  => ( is             => 'rw',
                                       isa            => 'CreditCardAttributeSet',
                                       traits         => [qw/Chargify::APIAttribute/],
                                       isAPIUpdatable => 1,
                                       coerce         => 1
                                     );
   has next_billing_at         => ( is             => 'rw',
                                    traits         => [qw/Chargify::APIAttribute/],
                                    isAPIUpdatable => 1,
                                  );
   has product_handle          => ( is             => 'rw',
                                    traits         => [qw/Chargify::APIAttribute/],
                                    isAPIUpdatable => 1,
                                  );
   has component               => ( is             => 'rw',
                                    isa            => 'WWW::Chargify::Component',
                                    traits         => [qw/Chargify::APIAttribute/],
                                    isAPIUpdatable => 1,
                                  );
   has cancel_at_end_of_period => ( is => 'rw', 
                                        isa => 'Bool', 
                                        default => 0, 
                                        traits => [qw/Chargify::APIAttribute/],
                                        );
   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   with 'WWW::Chargify::Role::Find';
   with 'WWW::Chargify::Role::List'; 
   with 'WWW::Chargify::Role::SimpleLogger';
   with 'WWW::Chargify::Role::Destroy';
   with 'WWW::Chargify::Role::Save';

   
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

      return  map { WWW::Chargify::Component->_from_hash
                   (
                    config => $config,
                    http => $http,
                    hash => { %{$_->{$component_hash_key }},
                              id => $_->{$component_hash_key}->{component_id}
                            } 
                   ) 
               } @{$objects}; 

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

   ## Adds the component to the object in question
   #
   sub add_usage_for_component {
       my ($class, %args ) =  validated_hash( \@_,
                                              component => { isa => 'WWW::Chargify::Component' },
                                              quantity  => { isa => 'Int'},
                                              memo      => { isa => 'Str' },
                                            );
       my ($object, $response ) = $class->http->post
                                  ( $class->_resource_key, 
                                    $class->id, 
                                    components => $args{component}->id, 
                                    usages => { usage => { quantity => $args{quantity} , memo => $args{memo} } 
                                              }
                                  );
   }
   sub usage_for_component {
       my ($class, %args )  = validated_hash
                              (\@_,
                               component => { isa => 'WWW::Chargify::Component'}
                              );
        my ($object, $response ) = $class->http->get
                                                 ( $class->_resource_key, 
                                                   $class->id, 
                                                   components => $args{component}->id, 
                                                 );

       return WWW::Chargify::Usage->_from_hash
              (
               config => $class->config,
               http   => $class->http,
               hash   => { %{$object->{$args{component}->_hash_key}} },
              );
   }
   
   # Migrates subscription on Chargify
   sub add_migration { 
       my ($class,%args) = validated_hash(\@_,
                                          migration => { isa => 'WWW::Chargify::Migration' }
                                         );
       my ($object,$response) = $class->http->post( 
                                                  $class->_resource_key,
                                                  $class->id, 
                                                   migrations => {
                                                                  migration => { 
                                                                                $args{migration}->_to_hash,
                                                                               }
                                                                 }
                                                  );
       return WWW::Chargify::Subscription->_from_hash
              (
               config => $class->config,
               http   => $class->http,
               hash   => { %{$object->{$class->_hash_key}}},
              );
   }


   #
   #
   sub usages {
       my ($class) = @_;
       
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

       my $http            = $args{http} || confess "http is required.";
       my $customer        = $args{customer}  || confess "customer is required.";
       my $product         = $args{product} || confess "product is required. ";
       my $creditcard      = $args{creditcard};
       my $coupon_code     = $args{coupon_code};
       my $next_billing_at = $args{next_billing_at};
       my $vat_number      = $args{vat_number};
       my $cancellation_message = $args{cancellation_message};

       # We are going to be creating a new subscription for a customer.
       # Now a customer could be new, in which case, we need to get hash for the customer, 
       #   otherwise we need to use the customer->reference, failing that the customer->id.
       
       my %hash = ();
       
       $hash{ product_handle } = $product->handle;

       if ($customer->has_id) {
         # So we have a customer that already exists in the system! Yay.
         debug( "Customer reference: ".$customer->reference );
         debug( "Customer id: ".$customer->id );
         $customer->has_reference ?
             ( $hash{customer_reference} = $customer->reference )
           : ( $hash{customer_id} = $customer->id );
       } else {
         $hash{ customer_attributes } = $customer->_to_hash_for_new_update;
       }

       if( $creditcard ){
          if( $creditcard->has_id ){
             $hash{ payment_profile_id } = $creditcard->id;
          } else {
             $hash{ payment_profile_attributes } = $creditcard->_to_hash_for_new_update;
          }
       }

       $hash{ coupon_code } = $coupon_code if( $coupon_code );
       $hash{next_billing_at} = DateTime::Format::W3CDTF->new->format_datetime($next_billing_at) if $next_billing_at ;
       $hash{vat_number} = $vat_number if $vat_number;
       $hash{cancellation_message} = $cancellation_message if $cancellation_message;

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
      my $hash = { product_handle    => $to_product->handle, };
      $hash->{ include_trial } = 1 if $include_trial;
      $hash->{ include_initial_charge} = 1 if $include_initial_charge;

      if( $preview ){
         my ($object, $response) = $http->post( $self->_resource_key, $self->id, migrations => 'preview.json', { migration => $hash } );
         return $object;  
      }
      my ($object, $response) = $http->post( $self->_resource_key, $self->id, 'migrations.json' => { migration => $hash } );
      return $self->_from_hash( http => $http, config => $http->config, hash => $object->{$self->_hash_key} );  
   }
   
   # 
   # handles the flags/ logic of adding a new credit card
   sub update_creditcard {
     my ($self, %args) =  validated_hash
                          (\@_,
                           credit_card => { isa => 'WWW::Chargify::CreditCard'}
                          );
     my @remove =  qw(cancel_at_end_of_period state customer_id id product_handle );
     my @toremove = grep { $b=$_;grep { $b->name eq $_ } @remove } $self->meta->get_all_attributes;
     my %remove = map { $_->name => $_->isAPIUpdatable } @toremove;
     #delete $self->{cancel_at_end_of_period};
     #delete $self->{state};
     #delete $self->{customer_id};
     # Deactivate certain parameters
     
     $_->isAPIUpdatable(0) foreach (@toremove);
     
     # delete the CVV ( possible bug in Chargify )
     delete $args{credit_card}->{cvv};

     $self->credit_card( $args{credit_card} );
     eval { 
         $self->save();
     };
     
     # Reset the parameters to their normal readonly state
     $_->isAPIUpdatable( $remove{$_->name} ) foreach ( @toremove );
     die $@ if( $@ );
   }


   sub reactivate {
     my ($self, %args) = @_;
     
     return if $self->state eq 'active' and !$self->cancel_at_end_of_period;
     my $http = $self->http;
     my $body = {};
     $body->{include_trial} = !!$args{include_trial} if exists $args{include_trial};
     my ($object, $response) = $http->put( $self->_resource_key, $self->id, reactivate => $body );
     return $self->_from_hash( http => $http, config => $http->config, hash => $object->{$self->_hash_key} );  
   }




   # curl -u $ENV{APIKEY}:x -X PUT "https://$ENV{SUBDOMAIN}.chargify.com/subscriptioF "subscription[id]=1301020" -F "subscription[vault_token]=5436078" -F "subscription[next_billing_at]=2012-02-20T22:40:58


   around save => sub {
       my ($orig, $class,%args) = @_;
       my $meta = $class->meta;

       if( $class->has_id ) { 

           $args{hash}->{next_billing_at} = 
             "$args{hash}->{next_billing_at}" if( $args{hash}->{next_billing_at} );
           $class->next_billing_at("" . $class->next_billing_at ) 
             if( defined $class->next_billing_at );
           
           # We would like the product to be replaced by it's integer
           if( defined $class->product->id ) { 
               $class->product_handle(  $class->product->handle );
           } 
           # Determine if there isn't a change
           if( defined $class->customer->id ) { 
               #$class->customer_vault_token( $class->customer->id );
               $class->customer_id( $class->customer->id );
           }

           if( $class->has_credit_card && !defined $class->credit_card->id ) {

               $class->credit_card_attributes( 
                                              $class->credit_card
                                             )
           }
       }

       $orig->($class, %args );
   };


1;

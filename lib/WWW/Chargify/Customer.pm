BEGIN {
    use 5.10.0;
    use MooseX::Declare;
    use MooseX::Types;
    use WWW::Chargify::Config;
    use WWW::Chargify::HTTP;
    use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
#    use DateTime;#
#    class_type 'DateTime';
};

use WWW::Chargify::Subscription;
use WWW::Chargify::Product;
use WWW::Chargify::CreditCard;

class WWW::Chargify::Customer {

   use WWW::Chargify::Utils::DateTime;
   use WWW::Chargify::Utils::Bool;

   
   has [qw/ first_name last_name email /]   => ( 
         traits => [qw/Chargify::APIAttribute/] , 
             is => 'rw' , 
            isa => 'Str' , 
       required => 1
   );

   has organization => ( 
          traits => [qw/Chargify::APIAttribute/],
              is => 'rw', 
             isa => 'Str', 
   );
   has reference => ( 
          traits => [qw/Chargify::APIAttribute/],
              is => 'rw', 
             isa => 'Str', 
       predicate => 'has_referece'
   );

   has id => ( 
               traits => [qw/Chargify::APIAttribute/] , 
                   is => 'rw' , 
                  isa => 'Num' , 
            predicate => 'has_id', 
       isAPIUpdatable => 0 
   );

   has [qw/ created_at updated_at /]        => ( 
               traits => [qw/Chargify::APIAttribute/],
                   is => 'rw' , 
                  isa => 'DateTime' , 
               coerce => 1,
       isAPIUpdatable => 0,
   );


   # Address Information. Did not see this in the API docs.
   # This will set the shipping address information for the user.
   has [qw/ address address_2 city country state zip /] => (
       traits => [qw/Chargify::APIAttribute/],
           is => 'rw' , 
          isa => 'Str' , 
   );

   has phone => (
       traits => [qw/Chargify::APIAttribute/],
           is => 'rw' , 
          isa => 'Str' , 
   );

   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   with 'WWW::Chargify::Role::List';
   with 'WWW::Chargify::Role::Find';
   with 'WWW::Chargify::Role::Save';

   sub _hash_key     { 'customer' };
   sub _resource_key { 'customers' };

   method find_by_reference( $class: WWW::Chargify::HTTP :$http, Str :$reference ){ 

      $class->_find_by( http => $http, params => [ lookup => {reference => $reference} ] ) 

   }

   method list_by_query( $class: WWW::Chargify::HTTP :$http, Str :$query ){ 
      $class->list(     http => $http, options => { q => $query, commit => 'Search' } ) 
   }

   method subscriptions {

      my $id = $self->id;
      my $config = $self->config;
      my $http = $self->http;
      my $resource_key = $self->_resource_key;
      my $subscription_hash_key = WWW::Chargify::Subscription->_hash_key;
      my $subscription_resource_key = WWW::Chargify::Subscription->_resource_key;
   
      my ($objects, $response) = $http->get($resource_key,$id,$subscription_resource_key);
      return map { WWW::Chargify::Subscription->_from_hash( 
         config => $config, 
           http => $http, 
           hash => $_->{$subscription_hash_key}  
      ) } @{$objects};

   }

   method add_subscription( WWW::Chargify::Product :$product, WWW::Chargify::CreditCard :$creditcard? ){

       my $http = $self->http;

       my $hash =  {
            product_handle     => $product->handle,
            customer_reference => $self->reference,
       };

       $hash->{ payment_profile_id } = $creditcard->id if $creditcard and $creditcard->id;
       my ($object, $response) = $http->post( WWW::Chargify::Subscription->_resource_key,  { WWW::Chargify::Subscription->_hash_key => $hash } );
       use Data::Dumper;
       print "Object: ".Dumper($object);
   }

}

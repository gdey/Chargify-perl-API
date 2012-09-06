package WWW::Chargify::Customer;
#class WWW::Chargify::Customer {
   use Moose;
   use MooseX::Types;
   use WWW::Chargify;
   use WWW::Chargify::Subscription;
   use WWW::Chargify::Product;
   use WWW::Chargify::CreditCard;
   use WWW::Chargify::Config;
   use WWW::Chargify::HTTP;
   use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
   use WWW::Chargify::Utils::DateTime;
   use WWW::Chargify::Utils::Bool;
   with 'WWW::Chargify::Role::SimpleLogger';
   
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
       predicate => 'has_reference'
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

   #method find_by_reference( $class: WWW::Chargify::HTTP :$http, Str :$reference ){ 
   sub find_by_reference {
      my ($class, %args) = @_;
      my $http = $args{http};
      my $reference = $args{reference};

      $class->_find_by( http => $http, params => [ lookup => {reference => $reference} ] ) 

   }

   #method list_by_query( $class: WWW::Chargify::HTTP :$http, Str :$query ){ 
   sub list_by_query {
      my ($class, %args) = @_;
      my $http = $args{http};
      my $query = $args{query};
      $class->list(     http => $http, options => { q => $query, commit => 'Search' } ) 
   }

   #method subscriptions {
   sub subscriptions {

      my ($self,$args) = @_;

      my $id = $self->id;

      return [] unless $id; # we are not saved.

      my $config = $self->config;
      my $http = $self->http;
      my $resource_key = $self->_resource_key;
      my $subscription_hash_key = WWW::Chargify::Subscription->_hash_key;
      my $subscription_resource_key = WWW::Chargify::Subscription->_resource_key;
      
      my $MAX_LIMIT = ( defined $args->{per_page} ? $args->{per_page} : 20 );
      my @retobj;
      $args->{page} = 1;
      my ($objects, $response) ;
      while(1) { 
          ($objects, $response) = $http->get($resource_key,$id,$subscription_resource_key,$args);
          my @tmp = sort {
              $b->id <=> $a->id
          } map { WWW::Chargify::Subscription->_from_hash( 
                                                          config => $config, 
                                                          http => $http, 
                                                          hash => $_->{$subscription_hash_key}  
                                                         ) } @{$objects};
          push @retobj, @tmp;
          last if( @tmp <  $MAX_LIMIT );
          $args->{page} ++;
      }
      return @retobj;
   }
   sub active_subscriptions {
       my ($self) = @_;
       return grep {$_->state eq "active" } $self->subscriptions;
   }

   sub add_subscription {
      
       my ($self, %args) = @_;
       my $product = $args{product} || confess "product is requried.";
       my %hash = (
          creditcard           => $args{creditcard},
          next_billing_at      => $args{next_billing_at},
          vat_number           => $args{vat_number},
          coupon_code          => $args{coupon_code},
          payment_profile_id   => $args{payment_profile_id},
          cancellation_message => $args{cancellation_message}
       );
       my %usehash = map { $_ => $hash{$_} } grep { defined $hash{$_} } keys %hash;

       my $newsubscription = WWW::Chargify::Subscription->add_subscription
                                                          (              
                                                           http => $self->http,
                                                           product => $product,
                                                           customer => $self,
                                                           %usehash 
                                                          );
       my $chash = $newsubscription->customer->_to_hash;
       $self->_save( hash => $chash );
       return $newsubscription;

   }

   sub all_credit_cards {
       my $self = shift;
       return map { $_->credit_card } 
             grep { $_->has_credit_card } $self->subscriptions
   }
   sub credit_cards {
       my $self = shift;
       return grep { !$_->is_expired } $self->all_credit_cards;
   }

   sub credit_card {
      my $self = shift;
      my ($cc, @i) = $self->credit_cards;
      return $cc;
   }

1;

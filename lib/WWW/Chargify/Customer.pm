BEGIN {
    use Modern::Perl;
    use MooseX::Declare;
    use MooseX::Types;
    use WWW::Chargify::Config;
    use WWW::Chargify::HTTP;
    use 5.10.0;
    use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
#    use DateTime;#
#    class_type 'DateTime';
};
    #use WWW::Chargify::CustomerFamily;

class WWW::Chargify::Customer {

   use Data::Dumper;
   use WWW::Chargify::Utils::DateTime;
   use WWW::Chargify::Utils::Bool;

   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   with 'WWW::Chargify::Role::List';
   with 'WWW::Chargify::Role::Find';
   
   has 'first_name'   => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] , required => 1);
   has 'last_name'    => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] , required => 1);
   has 'email'        => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] , required => 1);

   has 'organization' => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'reference'    => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );

   has 'id'           => ( is => 'rw' , isa => 'Num' , traits => [qw/Chargify::APIAttribute/] , predicate => 'has_id', isAPIUpdatable => 0 );
   has [qw/ created_at updated_at /]  => ( 
            traits => [qw/Chargify::APIAttribute/],
            is => 'rw' , 
            isa => 'DateTime' , 
            isAPIUpdatable => 0,
            coerce => 1,
   );


   # Address Information. Did not see this in the API docs.

   has 'address'      => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'address_2'    => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'city'         => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'country'      => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'phone'        => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'state'        => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'zip'          => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );

   sub _hash_key     { 'customer' };
   sub _resource_key { 'customers' };

   #{
   #   our %customer_families = ();
   #   around _from_hash( $class: WWW::Chargify::Config :$config, 
   #                 WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){

   #       my $customer_family_hash = $hash->{customer_family};
   #       if( $customer_family_hash ){
   #         my $pf_id = $customer_family_hash->{id};

   #         if( exists $customer_families{$pf_id} ){
   #            $hash->{customer_family} = $customer_families{$pf_id};
   #         } else {
   #            $hash->{customer_family} = WWW::Chargify::CustomerFamily->_from_hash(
   #                 config => $config,
   #                   http => $http,
   #                   hash => $hash,
   #              overrides => $overrides
   #            );
   #         }
   #       };
   #      return $orig->($class, http => $http, config => $config, hash => $hash, overrides => $overrides );
   #   }
   #}
   #
   #sub find_by {
   #   
   #   my ($class, $http, %args) = @_;
   #   return $class->_find_by(http => $http, params => [ $args{id} ]) 
   #          if( exists $args{id} );
   #   return $class->_find_by(http => $http, params => [ handle => $args{handle} ]) 
   #          if( exists $args{handle} );
   #   return undef;
   #}

   sub save {
       my ($self,%args) = @_;

       print "Save called!\n";

       my $hash = $self->_to_hash_for_new_update();
       print Dumper( $hash );
       # if there is an id, we need to put, otherwise we need to post.
       if( $self->has_id ){
          my ($res_hash, $response) =  $self->http->put( $self->_resource_key, $self->id, { $self->_hash_key => $hash } );
          print Dumper( $res_hash );
          
       } else {
       #$DB::signal = 1;
          my ($res_hash, $response) = $self->http->post( $self->_resource_key, { $self->_hash_key => $hash } );
          print "Repsonse Body: ".Dumper( $res_hash );

          foreach my $key ( keys %{$res_hash->{customer}} ){
             $self->$key($res_hash->{customer}->{$key}) if $res_hash->{customer}->{$key};
          }
          
       }
       #$DB::signal = 1;
       print "";
   }

   # sub _to_hash {
   #     my ($self) = @_;
   #     return { 
   #             $self->_hash_key =>
   #             { 
   #              address      => $self->address,
   #              address_2    => $self->address_2,
   #              city         => $self->city,
   #              country      => $self->country,
   #              email        => $self->email,
   #              first_name   => $self->first_name,
   #              last_name    => $self->last_name,
   #              organization => $self->organization,
   #              phone        => $self->phone,
   #              reference    => $self->reference,
   #              state        => $self->state,
   #              zip          => $self->zip,
   #             }
   #            };
   # }
}

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
   # This will set the shipping address information for the user.

   has 'address'      => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'address_2'    => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'city'         => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'country'      => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'phone'        => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'state'        => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );
   has 'zip'          => ( is => 'rw' , isa => 'Str' , traits => [qw/Chargify::APIAttribute/] );

   sub _hash_key     { 'customer' };
   sub _resource_key { 'customers' };

   method find_by_reference($class: WWW::Chargify::HTTP :$http, Str :$reference ){
        my $config = $http->config;
        return $class->_find_by($http => $http, params => [ reference => $reference ] ); 
   }

   method find_by_query( $class: WWW::Chargify::HTTP :$http, Str :$query ){

      my $options = { q => $query, commit => 'Search' };
      my @customers =  $class->list( http => $http, options => $options );

      return wantarray? @customers : \@customers;

   }

   method save {

       my $hash = $self->_to_hash_for_new_update();
       my ($res_hash, $response) = $self->has_id ? $self->http->put(  $self->_resource_key, $self->id, { $self->_hash_key => $hash } )
                                                 : $self->http->post( $self->_resource_key,            { $self->_hash_key => $hash } );
       # if there is an id, we need to put, otherwise we need to post.
       if ( $res_hash and $res_hash->{ $self->_hash_key } ){
          my %rhash = %{$res_hash->{ $self->_hash_key }};
          foreach my $key ( keys %rhash ){
             $self->$key($rhash{$key}) if $rhash{$key};
          }
       }
   }



}

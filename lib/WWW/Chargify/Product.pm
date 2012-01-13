use Modern::Perl;
use MooseX::Declare;
use WWW::Chargify::Config;
use WWW::Chargify::HTTP;
use WWW::Chargify::ProductFamily;

class WWW::Chargify::Product {

   use Data::Dumper;
   use DateTime;
   use WWW::Chargify::Utils::DateTime;
   use WWW::Chargify::Utils::Bool;
   
   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   with 'WWW::Chargify::Role::List';
   with 'WWW::Chargify::Role::Find';
   
       
   has name            => ( is => 'ro', isa => 'Str', required => 1 );
   has handle          => ( is => 'ro', isa => 'Str', required => 1 );
   has description     => ( is => 'ro', isa => 'Str', required => 1 );
   has accounting_code => ( is => 'ro', isa => 'Str', required => 1 );
   has interval_unit   => ( is => 'ro', isa => 'Str', required => 1 );
   has interval        => ( is => 'ro', isa => 'Str' );
   has trial_interval  => ( is => 'ro', isa => 'Num' );
   has return_url      => ( is => 'ro', isa => 'Str' );
   has return_params   => ( is => 'ro', isa => 'Str' );
   has created_at      => ( is => 'ro', isa => 'DateTime', coerce => 1 );
   has updated_at      => ( is => 'ro', isa => 'DateTime', coerce => 1 );
   has archived_at     => ( is => 'ro', isa => 'DateTime', coerce => 1 );
   has trial_interval_unit  => ( is => 'ro', isa => 'Str' );
   has expiration_interval  => ( is => 'ro', isa => 'Num' );
   has required_credit_card => ( is => 'ro', isa => 'Bool', coerce => 1 );
   has request_credit_card  => ( is => 'ro', isa => 'Bool', coerce => 1 );
   has expiration_interval_unit => ( is => 'ro', isa => 'Str' );
   has initial_charge_in_cents  => ( is => 'ro', isa => 'Num' );
   has trial_price_in_cents     => ( is => 'ro', isa => 'Num' );
   has id => ( is => 'ro', isa => 'Num' );
   has product_family  => ( is => 'ro', isa => 'WWW::Chargify::ProductFamily', required => 1 );

   sub _hash_key     { 'product' };
   sub _resource_key { 'products' };

   {
      our %product_families = ();
      around _from_hash( $class: WWW::Chargify::Config :$config, 
                    WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){

          my $product_family_hash = $hash->{product_family};
          if( $product_family_hash ){
            my $pf_id = $product_family_hash->{id};

            if( exists $product_families{$pf_id} ){
               $hash->{product_family} = $product_families{$pf_id};
            } else {
               $hash->{product_family} = WWW::Chargify::ProductFamily->_from_hash(
                    config => $config,
                      http => $http,
                      hash => $hash,
                 overrides => $overrides
               );
            }
          };
         return $orig->($class, http => $http, config => $config, hash => $hash, overrides => $overrides );
      }
   }
   
   sub find_by {
      
      my ($class, $http, %args) = @_;
      return $class->_find_by(http => $http, params => [ $args{id} ]) 
             if( exists $args{id} );
      return $class->_find_by(http => $http, params => [ handle => $args{handle} ]) 
             if( exists $args{handle} );
      return undef;
   }
}


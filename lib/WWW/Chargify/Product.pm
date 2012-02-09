package WWW::Chargify::Product;
use 5.010_000;
use feature ();
use Moose;
use WWW::Chargify::Config;
use WWW::Chargify::HTTP;
use WWW::Chargify::ProductFamily;

use Data::Dumper;
use DateTime;
use WWW::Chargify::Utils::DateTime;
use WWW::Chargify::Utils::Bool;

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';
with 'WWW::Chargify::Role::List';
with 'WWW::Chargify::Role::Find';

    
has name                     => ( is => 'ro', isa => 'Str', required => 1 );
has handle                   => ( is => 'ro', isa => 'Str', required => 1 );
has description              => ( is => 'ro', isa => 'Str', required => 1 );
has accounting_code          => ( is => 'ro', isa => 'Str', required => 1, default => '' );
has interval_unit            => ( is => 'ro', isa => 'Str', required => 1 );
has interval                 => ( is => 'ro', isa => 'Str' );
has trial_interval           => ( is => 'ro', isa => 'Num', default => 0 );
has return_url               => ( is => 'ro', isa => 'Str' );
has return_params            => ( is => 'ro', isa => 'Str' );
has created_at               => ( is => 'ro', isa => 'DateTime', coerce => 1 );
has updated_at               => ( is => 'ro', isa => 'DateTime', coerce => 1 );
has archived_at              => ( is => 'ro', isa => 'DateTime', coerce => 1 );
has trial_interval_unit      => ( is => 'ro', isa => 'Str' );
has expiration_interval      => ( is => 'ro', isa => 'Num', default => 0 );
has required_credit_card     => ( is => 'ro', isa => 'Bool', coerce => 1 );
has request_credit_card      => ( is => 'ro', isa => 'Bool', coerce => 1 );
has expiration_interval_unit => ( is => 'ro', isa => 'Str' );
has initial_charge_in_cents  => ( is => 'ro', isa => 'Num', default => 0 );
has trial_price_in_cents     => ( is => 'ro', isa => 'Num', default => 0 );
has price_in_cents           => ( is => 'ro', isa => 'Num', default => 0 );
has id                       => ( is => 'ro', isa => 'Num', predicate => 'has_id' );
has product_family           => ( is => 'ro', isa => 'WWW::Chargify::ProductFamily', required => 1 );

sub _hash_key     { 'product' };
sub _resource_key { 'products' };

#around _from_hash( $class: WWW::Chargify::Config :$config, 
#              WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){
{ 
    my %product_families = ();
around _from_hash =>  sub {

    my ($orig, $class, %args) = @_;
    # For some reason we are getting a warning of 
    #  '' is not numberic used with == warning.
    #  This warning does not seem to effect anything, 
    #   so, for this function, we are disabling the 
    #   warning.
    # Probally should use no warning 
    local $SIG{__WARN__} = sub {;}; # set it to a noop.
  

    my $http = $args{http} || confess 'http is required.';
    my $hash = $args{hash} || confess 'hash is requried.';
    my $config = $args{config} || confess 'config is required.';
    my $overrides = $args{overrides} || {};
    
    my $product_family_hash = $hash->{product_family};
    if( $product_family_hash and ref($product_family_hash) eq 'HASH'){
      my $pf_id = $product_family_hash->{id};

      if( exists $product_families{$pf_id} ){
         $hash->{product_family} = $product_families{$pf_id};
      } else {
         $hash->{product_family} = WWW::Chargify::ProductFamily->_from_hash(
              config => $config,
                http => $http,
                hash => $product_family_hash,
           overrides => $overrides,
         );
         $product_families{$pf_id} = $hash->{product_family};
      }
    };
    return $orig->($class, http => $http, config => $config, hash => $hash, overrides => $overrides );
};
}

#method find_by_handle( $class: WWW::Chargify::HTTP :$http, Str :$handle ) { 
sub find_by_handle {
   my ($class, %args) = @_;
   my $http = $args{http} || confess 'http is required.';
   my $handle = lc($args{handle}) || confess 'handle is required.';
   $class->_find_by( http => $http, params => [ handle => $handle ] ) 
}

sub find_by {
   
   my ($class, $http, %args) = @_;
   return $class->_find_by(http => $http, params => [ $args{id} ]) 
          if( exists $args{id} );
   return $class->_find_by(http => $http, params => [ handle => lc($args{handle}) ]) 
          if( exists $args{handle} );
   return undef;
}

sub price_in_dollars {

  my ($self, %args) = @_;
  return $self->price_in_cents * 100;

};

sub interval_string {

   my ($self ) = @_;

   my ($interval_unit,$interval) = ($self->interval_unit, $self->interval);

   
}

1;


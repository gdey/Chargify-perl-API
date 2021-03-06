package WWW::Chargify::ProductFamily;
use Moose;

use MooseX::Types::DateTime qw(DateTime);
use WWW::Chargify::HTTP;
use WWW::Chargify::Component;
use WWW::Chargify::Coupon;

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';
with 'WWW::Chargify::Role::List'; 
with 'WWW::Chargify::Role::Find';

has name => (
         is => 'ro',
        isa => 'Str',
   required => 1,
);

has handle => (
        is => 'ro',
       isa => 'Str',
  required => 1,
);

has description => (
        is => 'ro',
       isa => 'Str',
);

has accounting_code => (
        is => 'ro',
       isa => 'Str',
);

has id => (
        is => 'ro',
      isa => 'Num',
      required => 1,
);


sub _hash_key     { 'product_family' };
sub _resource_key { 'product_families' };

sub products {

   my $self = shift;

   my ($config, $http) = ($self->config, $self->http);
   my ($products, $response) = $self->http->get(product_families => $self->id, 'products');
   return map {
          WWW::Chargify::Product->_from_hash(
              http => $http,
              config => $config,
              hash => $_->{product} ,
              overrides => {
                  $self->_hash_key => $self
              });
   } @$products;

}

sub components {
   my $self = shift;
   my ($config, $http) = ($self->config, $self->http);
   my ($components_json, $response) = $http->get(product_families => $self->id, 'components');
   return map {
      my $component = $_->{component};
      WWW::Chargify::Component->_from_hash( config => $config, http => $http, hash => $component );
   } @$components_json;
}

sub coupons {
    my $self = shift;
    WWW::Chargify::Coupon->list( http => $self->http , options => { product_family_id => $self->id } );
}

sub active_coupons {
    my $self = shift;
    grep { !defined $_->archived_at  } $self->coupons();
}

#method find_component_by_id( Num $component_id ) {
sub find_component_by_id{

   my ($self, $component_id ) = @_;
   confess "component_id is requried." unless defined $component_id;

   my ($config, $http) = ($self->config, $self->http);
   my ($component_json, $response) = 
       $self->http->get(product_families => $self->id, components => $component_id);
   return undef unless $component_json;
   return WWW::Chargify::Component->_from_hash( config => $config, http => $http, hash => $component_json->{component} );
}

#method create_metered_component( Str :$name, Str :$unit_name, Num :$unit_price, Str :$pricing_scheme, ArrayRef :$prices ) {
sub create_metered_component{

   my ($self, %args) = @_;
   my $name = $args{name} || confess "name is required.";
   my $unit_name = $args{unit_name} || confess "unit_name is required.";
   my $unit_price = $args{unit_price}  || confess "unit_price is required.";
   my $pricing_scheme = $args{pricing_scheme} || confess "pricing_scheme is required.";
   my $prices = $args{prices} || confess "prices is required.";

   my ($component_json, $response) = 
      $self->http->post( product_families => $self->id, metered_components => { 
           metered_component => {
               name => $name,
               unit_name => $unit_name,
               pricing_scheme => $pricing_scheme,
               prices => $prices,
               unit_price => $unit_price
           }
      });
}


#method create_quantity_based_component( Str :$name, Str :$unit_name, Num :$unit_price, Str :$pricing_scheme, ArrayRef :$prices ) {
sub create_quantity_based_component{

   my ($self, %args) = @_;
   my $name = $args{name} || confess "name is required.";
   my $unit_name = $args{unit_name} || confess "unit_name is required.";
   my $unit_price = $args{unit_price}  || confess "unit_price is required.";
   my $pricing_scheme = $args{pricing_scheme} || confess "pricing_scheme is required.";
   my $prices = $args{prices} || confess "prices is required.";
   
   my ($component_json, $response) = 
      $self->http->post( product_families => $self->id, 
      
      quantity_based_component => {
          name           => $name,
          unit_name      => $unit_name,
          pricing_scheme => $pricing_scheme,
          prices         => $prices,
          unit_price     => $unit_price
      }

   );
}

#method create_on_off_component( Str :$name, Str :$unit_name, Num :$unit_price ) {
sub create_on_off_component {
   my ($self, %args) = @_;
   my $name = $args{name} || confess "name is required.";
   my $unit_name = $args{unit_name} || confess "unit_name is required.";
   my $unit_price = $args{unit_price}  || confess "unit_price is required.";

   my ($component_json, $response) = 
      $self->http->post( product_families => $self->id, on_off_components => {
          name       => $name,
          unit_name  => $unit_name,
          unit_price => $unit_price,
          price      => $unit_price,
   });
}


#method create_precentage_coupon 
#  ( 
#   Str :$name, 
#   Str :$code, 
#   Str :$description, 
#   Num :$percentage, 
#   Bool :$allow_negative_balance, 
#   Bool :$recurring, 
#   Num  :$coupon_duration_period_count,
#   DateTime :$coupon_end_date 
#  ) {
#    
#  return 1; 
#
#}

1;


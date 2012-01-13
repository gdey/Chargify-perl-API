use Modern::Perl;
use MooseX::Declare;
use MooseX::Types::DateTime qw(DateTime);
use WWW::Chargify::HTTP;
use WWW::Chargify::Component;

class WWW::Chargify::ProductFamily {

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';

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

method list ( $class: WWW::Chargify::HTTP :$http ) {
   my $config = $http->config;
   my ($product_families, $response) = $http->get('product_families');
   
   return map { $class->_from_hash( config => $config, http => $http, hash => $_->{product_family} ) }
   @{$product_families}
}

method find_by_id ($class: WWW::Chargify::HTTP :$http, Num :$id) {
   my $config = $http->config;
   my ($product_family, $response) = $http->get( product_families => $id );
   unless ( $product_family ) {
      use Data::Dumper;
      say "No product_family --- args: ".Dumper($id,$response);
      return undef;
   }
   return $class->_from_hash( config => $config, http => $http, hash => $product_family->{product_family} );
}

method products {

   my ($config, $http) = ($self->config, $self->http);
   my ($product_json, $response) = $self->http->get(product_families => $self->id, 'products');

   return map {
          my $product = $_->{product};
          #WWW::Chargify::Product->_from_hash(
          #   config => $config,
          #   http => $http,
          #   hash => $product,
          #   overrides => { product_family => $self }
          #);
          WWW::Chargify::Product->__product_with_json_hash( 
             http => $http, 
             config => $config, 
             product_json => $product, 
             product_family => $self );
   } @$product_json;

}

method components {
   my ($config, $http) = ($self->config, $self->http);
   my ($components_json, $response) = $http->get(product_families => $self->id, 'components');
   say 'Component: '.Dumper($components_json);
   return map {
      my $component = $_->{component};
      WWW::Chargify::Component->_from_hash( config => $config, http => $http, hash => $component );
   } @$components_json;
}

method find_component_by_id( Num $component_id ) {
   my ($config, $http) = ($self->config, $self->http);
   my ($component_json, $response) = 
       $self->http->get(product_families => $self->id, components => $component_id);
   say 'Component: '.Dumper($component_json);
   return undef unless $component_json;
   return WWW::Chargify::Component->_from_hash( config => $config, http => $http, hash => $component_json->{component} );
}

method create_metered_component( Str :$name, Str :$unit_name, Num :$unit_price, Str :$pricing_scheme, ArrayRef :$prices ) {

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


method create_quantity_based_components( Str :$name, Str :$unit_name, Num :$unit_price, Str :$pricing_scheme, ArrayRef :$prices ) {

   my ($component_json, $response) = 
      $self->http->post( product_families => $self->id, quantity_based_components => { 
      
      quantity_based_component => {
          name => $name,
          unit_name => $unit_name,
          pricing_scheme => $pricing_scheme,
          prices => $prices,
          unit_price => $unit_price
      }

      });
}

method create_on_off_component( Str :$name, Str :$unit_name, Num :$unit_price ) {

    my ($component_json, $response) = 
        $self->http->post( product_families => $self->id, on_off_components => {
               Name => $name,
               unit_name => $unit_name,
               unit_price => $unit_price,
               Price => $unit_price,
        });
}


method create_precentage_coupon ( 
    Str :$name, 
    Str :$code, 
    Str :$description, 
    Num :$percentage, 
    Bool :$allow_negative_balance, 
    Bool :$recurring, 
    Num  :$coupon_duration_period_count,
    DateTime :$coupon_end_date ) {

  return 1; 

};

}


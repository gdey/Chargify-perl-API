package WWW::Chargify::ProductFamily;
use v5.10.0;
use Moose;
use MooseX::Method::Signatures;


with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';

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

sub _from_hash {

	my ($class, $config, $http, %product_hash) = @_;
	my %pruned = map { $_ => $product_hash{$_} } grep { defined $product_hash{$_}} keys %product_hash;
	return $class->new(config => $config, http => $http, %pruned);
}

sub list {
   my ($class, $http) = @_;
   my ($product_families, $response) = $http->get('product_families');
   use Data::Dumper;
   say Dumper($product_families);
   return map { $class->_from_hash($http->config, $http, %{$_->{product_family}} ) }
   @{$product_families}
}

sub find_by_id {

   my ($class, $http, $id) = @_;
   my $product_family;
   my $response;
  
   use Data::Dumper;
   
   $product_family = $http->get( product_families => $id );
   unless ( $product_family ) {
      say "No product_family --- args: ".Dumper($id,$response);
      return undef;
   }
   return $class->_from_hash(config => $http->config, http => $http, %{$product_family->{product_family}});
}

method products {

   my ($product_json, $response) = $self->http->get(product_families => $self->id, 'products');

   return map {
          my $product = $_->{product};
          WWW::Chargify::Product->__product_with_json_hash( 
             http => $self->http, 
             config => $self->config, 
             product_json => $product, 
             product_family => $self );
   } @$product_json;

}

#method components {
#   my ($components_json, $response) = $self->http->get(product_families => $self->id, 'components');
#   say 'Component: '.Dumper($components_json);
#}
#
#method find_component_by_id( Num $component_id ) {
#   my ($component_json, $response) = 
#       $self->http->get(product_families => $self->id, components => $component_id);
#   say 'Component: '.Dumper($component_json);
#}

#method create_metered_component( Str :$name, Str :$unit_name, Num :$unit_price, Str :$pricing_scheme, ArrayRef :$prices ) {
#
#   my ($component_json, $response) = 
#      $self->http->post( product_families => $self->id, metered_components => { 
#      
#      metered_component => {
#          name => $name,
#          unit_name => $unit_name,
#          pricing_scheme => $pricing_scheme,
#          prices => $prices
#      }
#
#      });
#}
#
#
#method create_quantity_based_components( Str :$name, Str :$unit_name, Num :$unit_price, Str :$pricing_scheme, ArrayRef :$prices ) {
#
#   my ($component_json, $response) = 
#      $self->http->post( product_families => $self->id, metered_components => { 
#      
#      metered_component => {
#          name => $name,
#          unit_name => $unit_name,
#          pricing_scheme => $pricing_scheme,
#          prices => $prices
#      }
#
#      });
#}
#
#method create_on_off_component( Str :$name, Str :$unit_name, Num :$unit_price ) {
#
#}
#

1;


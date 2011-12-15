package WWW::Chargify;
use Moose;
use MooseX::Method::Signatures;

use LWP;
use HTTP::Request;


use namesapce::autoclean;

has apiKey => (
        is => 'r', 
       isa => 'Str',
  required => 1,
);

has apiPass => (
         is => 'r',
        isa => 'Str',
   required => 1,
    default => 'x',
);

has subdomain => (
           is => 'r',
          isa => 'Str',
      require => 1,
);



1;
__END__

=head1 Planned usage:

This is the way I plan on have the system work:

   use WWW::Chargify;
   my $chargify = WWW::Chargify->new(apiKey => 'key', subdomain => 'perlTest');

Getting a list of products.

   my @products = $chargify->products; # This returns an array of WWW::Chargify::Product Objects.

Getting a list of product families

   my @product_families = $chargify->product_families; 

Getting a product family via it's id

   my $product_family = $chargify->find_product_family( id => 'product_family_id')

Getting a product via the api_handle

   my $product = $chargify->find_product( handle => 'product-handle' ); # This returns a WWW::Chargify::Product Object
   my $product = $chargify->find_product( id => 'product-id' ); # This returns a WWW::Chargify::Product Object

Getting a list of products for a product_family via the product_family_id
   my @products = $chargify->find_product_family(id => 'product-family-id')->products;

Getting a list of components for a product_family
   my @components = $product_family->components;

Getting a compontent for a product family
  
   my $component = $product_family->find_component( id => 'component-id' );

Creating a Compontent metered type


   my $component = WWW::Chargify::Component::Type::Metered->new(
       config => $chargify->configuration,
       name => "New Component",
       unit_name => "component",
       pricing_scheme => WWW::Chargify::Component::Type::Metered::StairStep,
       prices => [
            {
                starting_quantity => 1,
                unit_price =>  1.0 
            },
            {
               ...
            }
       ]
   );
                                       

How coupon will work.

Finding coupons by code: 

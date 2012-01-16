package WWW::Chargify;
#use version 0.77; $VERSION = version->declare('v0.0.1');
use v5.10.0;
use Data::Dumper;
# ABSTRACT: wraper around Chargify.com's APIs.

use Moose;
use WWW::Chargify::Product;
use WWW::Chargify::Config;
use namespace::autoclean;
with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';

=head SYNOPIS

  my $chargify = WWW::Chargify->new( config => WWW::Chargify::Config->new( apiKey => 'xxxxxx', subdomain => 'perl-chargify' ) );
  my $chargify = WWW::Chargify->new( apiKey => 'xxxxx', subdomain => 'perl-chargify' );
  
=cut
  
  around BUILDARGS => sub {
     my ($orig, $class, %args) = @_;
     return $class->$orig( config => $args{config} ) if $args{config};
     return $class->$orig( config => WWW::Chargify::Config->new( %args ) );
     
  };

=method products

   This methods returns the list of WWW::Chargify::Product objects.

=cut 
  sub products {
      my $self = shift;
      return WWW::Chargify::Product->list( $self->http );
  }

  sub find_product_by {
      my $self = shift;
      my %args = @_;
      return WWW::Chargify::Product->find_by( $self->http, @_ );

  }

  sub product_families { return WWW::Chargify::ProductFamily->list( http => shift->http ); }

#
#  I want to change this to:
#
#   $chargify->find( ProductFamily => ( id => $id ) );
#   $chargify->find( Product => ( id => $id ) );
#   $chargify->find( Product => ( handle => $handle ) );

  sub find_product_family_by_id {
      my $self = shift;
      my $id   = shift;
      return WWW::Chargify::ProductFamily->find_by_id( http => $self->http, id => $id );
  }

  sub find_customer_by_id {
      my $self = shift;
      my $id = shift;
      return WWW::Chargify::Customer->find_by_id( http => $self->http, id => $id );
  }

  sub find_customer_by_reference {
      my $self = shift;
      my $reference = shift;
      return WWW::Chargify::Customer->find_by_reference( http => $self->http, reference => $reference );
  }

  sub find_customer_by_query {
      my $self = shift;
      my $query = shift;
      return WWW::Chargify::Customer->find_by_query( http => $self->http, query => $query );
  }

  sub newCustomer {
      my $self = shift;
      return WWW::Chargify::Customer->new( config => $self->config, http => $self->http, @_ );
  }
 
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


   my $component = $chargify->metered_component(name => 'New Component",...);
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

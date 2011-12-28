package WWW::Chargify::Product;
use v5.10.0;
use Moose;
use MooseX::Method::Signatures;
use WWW::Chargify::Config;
use WWW::Chargify::ProductFamily;

use Data::Dumper;
use DateTime;
use DateTime::Format::W3CDTF;

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';

    
has product_family  => ( is => 'ro', isa => 'WWW::Chargify::ProductFamily', required => 1 );
has name            => ( is => 'ro', isa => 'Str', required => 1 );
has handle          => ( is => 'ro', isa => 'Str', required => 1 );
has description     => ( is => 'ro', isa => 'Str', required => 1 );
has accounting_code => ( is => 'ro', isa => 'Str', required => 1 );
has interval_unit   => ( is => 'ro', isa => 'Str', required => 1 );
has interval        => ( is => 'ro', isa => 'Str' );
has trial_interval  => ( is => 'ro', isa => 'Num' );
has return_url      => ( is => 'ro', isa => 'Str' );
has return_params   => ( is => 'ro', isa => 'Str' );
has created_at      => ( is => 'ro', isa => 'DateTime' );
has updated_at      => ( is => 'ro', isa => 'DateTime' );
has archived_at     => ( is => 'ro', isa => 'DateTime' );
has trial_interval_unit  => ( is => 'ro', isa => 'Str' );
has expiration_interval  => ( is => 'ro', isa => 'Num' );
has required_credit_card => ( is => 'ro', isa => 'Bool' );
has request_credit_card  => ( is => 'ro', isa => 'Bool' );
has expiration_interval_unit => ( is => 'ro', isa => 'Str' );
has initial_charge_in_cents  => ( is => 'ro', isa => 'Num' );
has trial_price_in_cents     => ( is => 'ro', isa => 'Num' );
has id => ( is => 'ro', isa => 'Num' );

{
   my %product_families = ();
   sub __product_with_json_hash {
   
       my ($class, %args) = @_;
       my $http    = $args{http};
       my $config  = $args{config};
       my $product = $args{product_json};
       my $prodfam = $args{product_family} // 
                     $product_families{ $product->{product_family}->{id} };
   
       if( !$prodfam ){
   
          my %pdh = %{$product->{product_family}};
          my %pd = map { $_ => $pdh{ $_ } } grep { defined $pdh{ $_ } } keys %pdh;
   
          $prodfam =  WWW::Chargify::ProductFamily->new( config => $http->config, http => $http, %pd );
          $product_families{ $prodfam->id } = $prodfam;
       }
   
       my %pdh = ( %{$product} ); 
       delete $pdh{product_family};
      
       my %p = map { $_ => $pdh{ $_ } } grep { defined $pdh{ $_ } } keys %pdh;
       $p{created_at} = DateTime::Format::W3CDTF->new->parse_datetime($p{created_at}) if exists $p{created_at};
       $p{updated_at} = DateTime::Format::W3CDTF->new->parse_datetime($p{updated_at}) if exists $p{updated_at};
       $p{archived_at} = DateTime::Format::W3CDTF->new->parse_datetime($p{archived_at}) if exists $p{archived_at};
       $p{required_credit_card} = 1 == $p{required_credit_card} if exists $p{required_credit_card};
       $p{request_credit_card}  = 1 == $p{request_credit_card}  if exists $p{request_credit_card};
   
       $class->new( 
           config => $http->config, 
           http => $http, 
           product_family => $prodfam, 
              %p );
   }
   
   sub list {

      my ($class, $http) = @_;
      my ($products, $response) = $http->get('products');
      my @products = map {
          $class->__product_with_json_hash( 
             http => $http, 
             config => $http->config, 
             product_json => $_->{product}, 
         );
      } @$products;
   
      return @products;
   }

   sub find_by {
      
      my ($class, $http, %args) = @_;

      if( exists $args{id} ){
          my ($product, $response) = $http->get( products => $args{id} );
          return $class->__product_with_json_hash(
             http => $http,
             config => $http->config,
             product_json => $product->{product}
          );
      }

      if( exists $args{handle} ){
          my ($product, $response) = $http->get( 'products', handle => $args{handle} );
          return $class->__product_with_json_hash(
             http => $http,
             config => $http->config,
             product_json => $product->{product}
          );
      }

   }
}

1;

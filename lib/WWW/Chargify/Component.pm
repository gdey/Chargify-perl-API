package WWW::Chargify::Component;
use Moose;


with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';

has name => ( is => 'ro', isa => 'Str', required => 1 );
has unit_name =>  ( is => 'ro', isa  => 'Str' );
has unit_price => ( is => 'ro', isa => 'Num' );
# For pricing scheme we should use an enum with the following values
# per_unit, volume, tiered, stairstep
has pricing_scheme => ( is => 'ro', isa => 'Str' ); 
has prices => (is => 'ro', isa => 'ArrayRef' );
has product_family => ( is => 'ro', isa => 'WWW::Chargify::ProductFamily');
has kind => (is => 'ro', isa => 'Str' );

1;



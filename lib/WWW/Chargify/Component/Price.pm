use Modern::Perl;
use MooseX::Declare;
class WWW::Chargify::Component::Price {

   with 'WWW::Chargify::Role::FromHash';

   has ending_quantity => (is => 'ro', isa => 'Num');
   has starting_quantity => (is => 'ro', isa => 'Num', default => 0);
   has unit_price => ( is => 'ro', isa => 'Num' );

};

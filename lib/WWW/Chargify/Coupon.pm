package WWW::Chargify::Coupon;
use Moose;
use namespace::clean;

   has [qw/ name code description /] => (
      traits => [qw/Chargify::APIAttribute/],
      is => 'rw',
      isa => 'Str',
      required =>  1
   );

   has percentage => (
      traits => [qw/Chargify::APIAttribute/],
      is => 'rw',
      isa => 'Int',
      predicate => 'has_percentage',
      clearer => 'clear_percentage',
      trigger => sub {
         my $self = shift;
         $self->clear_amount;
      }
   );

   has amount => (
      traits => [qw/Chargify::APIAttribute/],
      is => 'rw',
      isa => 'Str',
      predicate => 'has_amount',
      clearer => 'clear_amount',
      trigger => sub {
         my $self =  shift;
         $self->clear_percentage;
      }
   );

   has [qw/allow_negative_balance recurring/] => (
      traits => [qw/Chargify::APIAttribute/],
      is => 'rw',
      isa => 'Bool',
      default => sub { 0 },
   );

   # has product_family_id => ( 
   #    is  => 'rw',
   #    isa => 'Int'                       
   #                           );


with 'WWW::Chargify::Role::SimpleLogger';
with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';
with 'WWW::Chargify::Role::List';



sub _hash_key     { 'coupon' };
sub _resource_key { 'coupons' };




1;

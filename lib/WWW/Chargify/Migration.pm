package WWW::Chargify::Migration;
use Moose;
use namespace::clean;

   has [qw/ product_handle /] => (
      traits => [qw/Chargify::APIAttribute/],
      is => 'rw',
      isa => 'Str',
      required =>  1
   );

   has include_trial => (
      traits => [qw/Chargify::APIAttribute/],
      is => 'rw',
      isa => 'Bool',
   );
   has product      => ( 
                        is => 'rw',
                        isa => 'WWW::Chargify::Product'
                       );

   has include_initial_charge => (
      is => 'rw',
      isa => 'DateTime',
      coerce => 1,
   );

with 'WWW::Chargify::Role::SimpleLogger';
with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';
with 'WWW::Chargify::Role::List';

sub _hash_key     { 'migration' };
sub _resource_key { 'migrations' };


1;

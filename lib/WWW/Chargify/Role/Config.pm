package WWW::Chargify::Role::Config;
use Moose::Role;
use WWW::Chargify::Config;
   
   has config => ( is => 'ro', isa => 'WWW::Chargify::Config', required => 1 );

1;

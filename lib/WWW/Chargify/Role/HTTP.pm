package WWW::Chargify::Role::HTTP;
use Moose::Role;
use WWW::Chargify::HTTP;

 requires 'config';

 has http => ( 
          is => 'ro',
          isa => 'WWW::Chargify::HTTP', 
          required => 1,
          lazy => 1,
          builder => '_build_http'
      );

sub _build_http {
   my $self = shift;
   return WWW::Chargify::HTTP->new( config => $self->config );
}

1;

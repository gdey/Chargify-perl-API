package WWW::Chargify::Config;
use Moose;

   has apiKey => (
           is => 'ro', 
          isa => 'Str',
     required => 1,
   );
   
   has apiPass => (
            is => 'ro',
           isa => 'Str',
      required => 1,
       default => 'x',
   );
   
   has subdomain => (
              is => 'ro',
             isa => 'Str',
        required => 1,
   );
   
   has chargify_url => (
              is => 'ro',
             isa => 'Str',
         default => 'chargify.com'
   );

   has protocal => (
         is => 'ro',
         isa => 'Str',
         default => 'https'
   );

   sub base_url {
      my ($self, $path ) = @_;
      return $self->protocal.'://'.$self->subdomain.'.'.$self->chargify_url.'/'.$path;
   }
1;

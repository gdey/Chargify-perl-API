package WWW::Chargify::Role::Config;
use Moose::Role;
use WWW::Chargify::Config;
   
   has config => ( 
       is => 'ro', 
       isa => 'WWW::Chargify::Config', 
       required => 1,
       lazy => 1,
       builder => '_build_config'
  );

sub _build_config {
   my $self = shift;
   my $config; # = WWW::Chargify->config; #Not implemented yet. :(
   $config = WWW::Chargify->config( subdomain => $ENV{CHARGIFY_SUBDOMAIN}, apiKey => $ENV{CHARGIFY_APIKEY} )
       if !$config and ( exists $ENV{CHARGIFY_SUBDOMAIN} and exists $ENV{CHARGIFY_APIKEY} );
   confess "Need WWW::Chargify::Config object, please create one, or set the environment variables CHARGIFY_SUBDOMAIN and CHARGIFY_APIKEY" 
       unless $config;
   return $config;
}
1;

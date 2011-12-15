use MooseX::Declare;
use Constant    GET => 'GET';
use Constant    PUT => 'PUT';
use Constant   POST => 'POST';
use Constant DELETE => 'DELETE';
use Constant   HEAD => 'HEAD';

enum HTTP_METHODS => [qw( HEAD POST PUT GET DELETE )];

class WWW::Chargify::HTTP {

   use HTTP::Request;
   use LWP::UserAgent;
   use Carp qw(confess);

   has config => (
             is => 'ro',
            isa => 'WWW::Chargify::Configuration',
       required => 1
   );

   method post (Str :path!, HashRef :params) {
      # For get we don't have a body as well.
      $self->make_request($path, $params, POST );
   }

   method put (Str :path!, HashRef :params) {
      $self->make_request($path, $params, PUT );
   }

   method get (Str :path!, HashRef :params) {
      $self->make_request($path, $params, GET );
   }

   method delete (Str :path!, HashRef :params) {
      # For delete we don't have a body.
      $self->make_request($path, undef, DELETE);
   }

   method head (Str :path!, HashRef :params) {
      # For head we don't have a body.
      $self->make_request($path, undef, HEAD);
   }

   method make_request (Str :path, HashRef :params, HTTP_METHODS :method) {
       my $base_url = $self->config->base_url;
       my $request = HTTP::Request->new(
   }




}
1;


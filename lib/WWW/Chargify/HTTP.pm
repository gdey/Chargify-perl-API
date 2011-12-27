package WWW::Chargify::HTTP;
use v5.10.0;

use Moose;
use Moose::Util::TypeConstraints;

use JSON;
use HTTP::Request;
use LWP::UserAgent;
use Carp qw(confess);
use Data::Dumper;

enum HTTP_METHODS => [qw( HEAD POST PUT GET DELETE )];


with 'WWW::Chargify::Role::Config';


has userAgent => (
         is   => 'rw',
        isa   => 'LWP::UserAgent',
       lazy   => 1,
       builder => '_build_user_agent'
);

sub _build_user_agent {
   my $self = shift;
   my $ua = LWP::UserAgent->new( agent => 'chargify-perl/0.0.1' );
   return $ua;
}

sub set_body {

   my ($self, %args ) = @_;
   my $request = $args{request};
   my $body = $args{body};

   return unless $body;
   my $json = encode_json $body;
   $request->content($json);
   $request->headers->content_type('Application/json; charset=utf-8');

}

sub post {
   my ($self, @path) = @_;
   my $body = pop @path;
   my $path = join '/',@path;
   $self->make_request( POST => $path, $body // "{}");
}
sub put {
   my ($self, @path) = @_;
   my $body = pop @path;
   my $path = join '/',@path;
   $self->make_request( PUT => $path, $body // "{}");
}
sub get {
   my ($self, @path) = @_;
   my $path = join '/',@path;
   $self->make_request( GET => $path);
}
sub head {
   my ($self, @path) = @_;
   my $path = join '/',@path;
   $self->make_request( HEAD => $path);
}
sub delete {
   my ($self, @path) = @_;
   my $path = join '/',@path;
   $self->make_request( DELETE => $path);
}

sub make_request {
   my ($self, $method, $path, $body) = @_;


   my $base_url = $self->config->base_url($path);
   my $request = HTTP::Request->new( $method => $base_url );
   $request->headers->authorization_basic(
      $self->config->apiKey,$self->config->apiPass
   );
   $self->set_body($request, $body);
   my $response = $self->userAgent->request($request);
   if ( $response->is_success ) {
       my $value = decode_json($response->decoded_content);
       return wantarray? ($value,$response) : $value;
   }

   #TODO:  Need to handle errors here.


   
   return wantarray? (undef,$response) : undef;
} 

1;


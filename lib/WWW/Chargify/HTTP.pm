package WWW::Chargify::HTTP;
use v5.10.0;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::LWP::UserAgent qw(UserAgent);

use JSON;
use HTTP::Request;
use LWP::UserAgent ();
use Carp qw(confess);
use Data::Dumper;
use namespace::autoclean;

enum HTTP_METHODS => [qw( HEAD POST PUT GET DELETE )];

with 'WWW::Chargify::Role::Config';


has userAgent => (
         is   => 'rw',
        isa   => UserAgent,
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

   print "Body: $body\n";

   $request->headers->content_type('application/json; charset=utf-8');
   return unless $body;
   my $json = encode_json $body;
   $request->content($json);

}

sub filter_string {
   my ($self, $hash_ref) = @_;

   my @filter = ();
   foreach my $key ( keys %{$hash_ref} ){
      my $value = $hash_ref->{$key};
      unless ( ref($value) )  {
         push @filter, $key.'='.$value;
         next; 
      }
      if( ref($value) eq 'ARRAY' ){
         push @filter, map {$key.'[]='.$_} @{$value};
         next;
      } 
   }

   return join '&', @filter;
}

sub post {
   my ($self, @path) = @_;
   my $body = pop @path if ref($path[-1]) eq 'HASH';
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   say 'Path : '.Dumper(\@path);
   my $path = join '/', @path;

   say 'Path: '.$path.'Body: '.Dumper($body);

   $self->make_request( POST => $path, $options // {}, $body // "{}");
}
sub put {
   my ($self, @path) = @_;
   my $body = pop @path if ref($path[-1]) eq 'HASH';
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/',@path;
   $self->make_request( PUT => $path, $options // {}, $body // "{}");
}
sub get {
   my ($self, @path) = @_;
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/',@path;
   $self->make_request( GET => $path, $options);
}
sub head {
   my ($self, @path) = @_;
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/',@path;
   $self->make_request( HEAD => $path, $options);
}
sub delete {
   my ($self, @path) = @_;
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/',@path;
   $self->make_request( DELETE => $path, $options);
}

sub check_response_code {

	my ($self, $response) = @_;
  my $code = $response->code;
	confess 'NotFoundError'       if $code eq '404';
	confess 'UnprocessableEntity: '.$response->decoded_content if $code eq '422';
  confess 'AuthenticationError' if $code eq '401';
  confess 'AuthorizationError'  if $code eq '403';
  confess 'ServerError'         if $code eq '500';
  confess 'DownForMaintenance'  if $code eq '503';

}

sub make_request {

   my ($self, $method, $path, $options, $body) = @_;

   $path .='?'.$self->filter_string($options) if $options;
   my $base_url = $self->config->base_url($path);
   my $request = HTTP::Request->new( $method => $base_url );
   $request->header(Accept => 'application/json');
   $request->headers->authorization_basic(
      $self->config->apiKey,$self->config->apiPass
   );
   say "Doing: $method => $base_url";

   say 'Body: '.Dumper($body) if $body;
   $self->set_body( request => $request, body => $body );
   my $response = $self->userAgent->request($request);
   if ( $response->is_success ) {
       say 'got back: '.$response->decoded_content;
       my $value = decode_json($response->decoded_content);
       return wantarray? ($value,$response) : $value;
   }

   #TODO:  Need to handle errors here.
   $self->check_response_code($response);
   return wantarray? (undef,$response) : undef;
} 

1;


package WWW::Chargify::HTTP;
use v5.10.0;

use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::LWP::UserAgent qw(UserAgent);
use WWW::Chargify::Role::JsonWrap;
use WWW::Chargify::Exception;
use HTTP::Request;
use LWP::UserAgent ();
use Carp qw(confess);
use Data::Dumper;
use namespace::autoclean;
use Try::Tiny;

with 'WWW::Chargify::Role::SimpleLogger';

enum HTTP_METHODS => [qw( HEAD POST PUT GET DELETE )];

with 'WWW::Chargify::Role::Config';


has userAgent => (
         is   => 'rw',
        isa   => UserAgent,
       lazy   => 1,
       builder => '_build_user_agent'
);

has extra_headers => (
       traits => ['Hash'],
       is => 'ro',
       isa => 'HashRef[Str]',
       default => sub { {} },
       handles => {
          set_extra_header => 'set',
          get_extra_header => 'get',
          has_no_extra_headers => 'is_empty',
          has_extra_headers => 'count',
          extra_header_keys => 'keys',
          extra_header_values => 'values',
          extra_header_pairs => 'kv',
          clear_extra_headers => 'clear',
          all_extra_headers => 'elements',
       }

);

sub _build_user_agent {
   my $self = shift;
   my $ua = LWP::UserAgent->new( agent => 'chargify-perl/0.0.8');
   $ua->{ssl_opts}->{verify_hostname} = undef;
   return $ua;
}


sub set_body {

   my ($self, %args ) = @_;
   my $request = $args{request};
   my $body = $args{body};
   local $SIG{__WARN__} = sub { ;
      #debug( "Got warning for the following body: ".Dumper($body)."\n")
   }; # set it to a noop.
   $request->headers->content_type('application/json; charset=utf-8');
   return unless $body;
   my $json = encode_json $body;
   $request->content($json);

}

sub filter_string {
   my ($self, $hash_ref) = @_;

   my @filter = ();
   foreach my $key ( sort keys %{$hash_ref} ){
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
   my $path = join '/', @path;
   debug('Path: '.$path.'Body: '.Dumper($body) );

   $self->make_request( POST => $path, $options // {}, $body // {});
}
sub put {
   my ($self, @path) = @_;
   my $body = pop @path if ref($path[-1]) eq 'HASH';
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/', grep { defined } @path;
   debug('Path: '.$path.'Body: '.Dumper($body) );
   $self->make_request( PUT => $path, $options // {}, $body // {});
}
sub get {

   my ($self, @path) = @_;
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/', grep { defined } @path;
   debug('Path: $path' . "Options: " . Dumper($options));
   $self->make_request( GET => $path, $options);
}

sub head {
   my ($self, @path) = @_;
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/', grep { defined } @path;
   $self->make_request( HEAD => $path, $options);
}

sub delete {
   my ($self, @path) = @_;
   my $options = pop @path if ref($path[-1]) eq 'HASH';
   my $path = join '/', grep { defined } @path;
   debug('Path: $path' . "Options: " . Dumper($options));
   $self->make_request( DELETE => $path, $options);
}

sub check_response_code {

  my ($self, $response, $sent_body, $request) = @_;
  $sent_body = '<<EMPTY BODY>>' unless defined $sent_body;
  my $errors;
  my $code = $response->code;
  my $content = $response->content;

  my $error_type = 'UNKNOWN'; 

  $error_type = 'AuthenticationError'   if $code eq '401';
  $error_type = 'AuthorizationError'    if $code eq '403';
  $error_type = 'NotFoundError'         if $code eq '404';
  $error_type = 'UnprocessableEntity: ' if $code eq '422';
  $error_type = 'ServerError'           if $code eq '500';
  $error_type = 'DownForMaintenance'    if $code eq '503';
  if( $content !~ /^\s*$/ ) { 
    try {
      my $obj = JSON::decode_json( $content );
      if (ref($obj) eq 'HASH'){
        $errors =$obj->{errors};
      } elsif ( ref($obj) eq 'ARRAY' ){
        $errors = $obj->[1];
      };
    } catch {
       if( $code eq '401' or $code eq '403' ){
          $errors = [ (($code eq '401')? 'Authorization Error:' : 'Authentication Error' ) . 'Are the API keys for chargify correct?' ];
       } elsif( $code eq '404' ){
          $errors = [ 'NotFoundError: Chargify API seems to have changed. ' ];
       } elsif( $code eq '422' ){
          $errors = [ 'UnprocessableEntity: Chargify API seems to have changed. ' ];
       } elsif( $code eq '500' ){
          $errors = [ 'ServerError: Chargify API is returning a server error. ' ];
       } elsif( $code eq '503' ){
          $errors = [ 'DownForMaintence: Chargify is down for maintance, try the call at a later time.' ];
       } else {
          $errors = [ "UNKNOWN( $code ) : Chargify API is returning an unknown error. " ];
       }
    };
  }
  die WWW::Chargify::Exception->new(    
                                        request  => $request,
                                        response => $response,
                                        code     => $code,
                                        type     => $error_type,
                                        errors   => $errors,
                                   )
}

sub make_request {


   my ($self, $method, $path, $options, $body) = @_;

   $path .='?'.$self->filter_string($options) if $options;

   my $base_url = $self->config->base_url($path);
   my $request = HTTP::Request->new( $method => $base_url );
   $request->header(Accept => 'application/json');
   if( $self->has_extra_headers ){
      foreach my $pair ( $self->extra_header_pairs ) {
         $request->header( $pair->[0] => $pair->[1] );
      }
   }
   $request->headers->authorization_basic(
      $self->config->apiKey,$self->config->apiPass
   );
   debug("Doing: $method => $base_url");
   debug("Body: " . Dumper($body)) if $body;

   $self->set_body( request => $request, body => $body );

   my $content_body = $request->content;

   my $response = $self->userAgent->request($request);
   if ( $response->is_success ) {
       my $value = decode_json($response->decoded_content);
       return wantarray? ($value,$response) : $value;
   }

   debug("Body: " . Dumper($content_body)) if $content_body;
   #TODO:  Need to handle errors here.
   $self->check_response_code($response, $content_body, $request);
   return wantarray? (undef,$response) : undef;
} 

1;


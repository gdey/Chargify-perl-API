#
#
#
package WWW::Chargify::Exception;
use strict;
use Moose;
use JSON ();
use HTTP::Request;
use overload 
    '""' => \&to_s,
    'bool' => \&to_bool,
    'ne' => sub { return ! str_compare(@_)},
    'eq' => \&str_compare;

has 'request'    => ( is => 'ro', isa => 'HTTP::Request', required => 0  );
has 'response'   => ( is => 'ro', isa => 'HTTP::Response'       );
has 'errors'     => ( is => 'rw', isa => 'ArrayRef[Str]|Undef'  );
has 'code'       => ( is => 'rw', isa => 'Int'                  );
has 'type'       => ( is => 'rw', isa => 'Str'                  ); 
sub status_code {
    my ($self) = @_;
    $self->code;
}
##
#
sub to_bool { return !!0; }
sub to_s {
    my ($self) = @_;
    my $errors;
    if( ref $self->errors eq "HASH" ) {
        $errors = "errors: " . JSON::encode_json( $errors );
    } else {
        $errors = "";
    }
    $self->type . " (" . $self->code . ") : $errors";
}
sub str_compare { 
    return "$_[0]" eq "$_[1]";
}


1;

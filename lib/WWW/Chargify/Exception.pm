#
#
#
package WWW::Chargify::Exception;
use strict;
use Moose;
use JSON ();
use overload 
    '""' => \&to_s,
    'ne' => sub { return ! str_compare(@_)},
    'eq' => \&str_compare;

has 'response'   => ( is => 'ro', isa => 'HTTP::Response'       );
has 'errors'     => ( is => 'rw', isa => 'ArrayRef[Str]|Undef'  );
has 'code'       => ( is => 'rw', isa => 'Int'                  );
has 'type'       => ( is => 'rw', isa => 'Str'                  ); 
sub status_code {
    goto &code;
}
##
#
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

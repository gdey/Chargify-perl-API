package WWW::Chargify::Role::Destroy;
use Moose::Role;

   requires '_resource_key';
   requires 'id';
   
   sub cancel { goto &destroy; }

   sub destroy {
       my $self = shift;
       return $self->http->delete( $self->_resource_key, $self->id );
   }


1;

package WWW::Chargify::Role::Destroy;
use Moose::Role;

   requires '_to_hash_for_new_update';
   requires '_hash_key';
   requires '_resource_key';
   requires 'id';
   requires 'has_id';
   requires 'meta';
   requires '_apiName_to_attributeName';
   sub cancel {
       goto &destroy;
   }

   sub destroy {
       my $self = shift;

       my $meta = $self->meta;
       my $hash = $self->_to_hash_for_new_update();

       my ($res_hash, $response ) = $self->http->delete( $self->_resource_key, $self->id );
       # $self->_save( hash => $res_hash->{ $self->_hash_key } )
       #           if ( $res_hash and $res_hash->{ $self->_hash_key } );
   }


1;

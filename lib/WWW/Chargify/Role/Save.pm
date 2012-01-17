use Modern::Perl;
use MooseX::Declare;

role WWW::Chargify::Role::Save {

   requires '_to_hash_for_new_update';
   requires '_hash_key';
   requires '_resource_key';
   requires 'id';
   requires 'has_id';
   requires 'meta';

   method save {

       my $meta = $self->meta;
       my $hash = $self->_to_hash_for_new_update();

       # if there is an id, we need to put, otherwise we need to post.
       my ($res_hash, $response) = $self->has_id 
                                 ? $self->http->put(  $self->_resource_key, $self->id, { $self->_hash_key => $hash } )
                                 : $self->http->post( $self->_resource_key,            { $self->_hash_key => $hash } );

       if ( $res_hash and $res_hash->{ $self->_hash_key } ){

          my %rhash = %{$res_hash->{ $self->_hash_key }};

          foreach my $key ( keys %rhash ){

             next unless $rhash{$key};

             my $attribute = $meta->get_attribute( $self->_apiName_to_attributeName($key) );
             next unless $attribute;

             my $setter = $attribute->get_write_method;
             next unless $setter; # This is a read only attribute.
             $self->$setter($rhash{$key}); 
          }

       }
   }

};


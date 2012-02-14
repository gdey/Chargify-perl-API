package WWW::Chargify::Role::Save;
use Moose::Role;


   requires '_to_hash_for_new_update';
   requires '_hash_key';
   requires '_resource_key';
   requires 'id';
   requires 'has_id';
   requires 'meta';
   requires '_apiName_to_attributeName';

   #method _save( HashRef :$hash ) {
   sub _save {

      my ($self, %args) = @_;
      my $hash = $args{hash};

      my $meta = $self->meta;
      my %rhash = %{$hash};
      foreach my $key ( keys %rhash ){

         next unless $rhash{$key};
         my $attribute = $meta->get_attribute( $self->_apiName_to_attributeName($key) );
         next unless $attribute;
         my $setter = $attribute->get_write_method;
         next unless $setter; # This is a read only attribute.
         $self->$setter( $self->_determine_type( $key,  $rhash{$key} )  ); 
      }
   }
   sub _determine_type {
       my ($self, $key, $value ) = @_;
       if( ref $value eq "HASH" ) { 

           my $objtype = _camel_case_class( $key );
             return "WWW::Chargify::${objtype}"->_from_hash 
                                                (  
                                                 http   => $self->http,
                                                 config => $self->config,
                                                 hash   => $value,
                                                );
       } else {
           return $value;
       }
   }

   sub save {
       my $self = shift;

       my $meta = $self->meta;
       my $hash = $self->_to_hash_for_new_update();

       # if there is an id, we need to put, otherwise we need to post.

       my ($res_hash, $response) = $self->has_id 
                                 ? $self->http->put(  $self->_resource_key, $self->id, { $self->_hash_key => $hash } )
                                 : $self->http->post( $self->_resource_key,            { $self->_hash_key => $hash } );

       $self->_save( hash => $res_hash->{ $self->_hash_key } )
                 if ( $res_hash and $res_hash->{ $self->_hash_key } );
   }
   sub _camel_case_class { 
       my ($tmp) = @_; 
       return join "", map { $_ =~ s/^(.)(.*)/uc($1).$2/eg; $_ } split("_", $tmp)
   }


1;

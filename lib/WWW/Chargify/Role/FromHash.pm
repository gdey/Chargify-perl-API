use Modern::Perl;
use MooseX::Declare;
use WWW::Chargify::Utils::DateTime;

role WWW::Chargify::Role::FromHash{

method _from_hash( $class: WWW::Chargify::Config :$config, 
                    WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){

	# Expect %args to have the following:
	#  hash => A hash ref containing the values to from the new object with.
	#  overrides => Overrides for those values.
	#  http => a WWW::Chargify::HTTP object.
	#  config => a WWW::Chargify::Config object.

	my %pruned = map  { $_ => $hash->{$_}   } 
               grep { defined $hash->{$_} } 
               keys %{$hash};
  $pruned{$_} = $overrides->{$_} foreach keys %{$overrides};
	return $class->new(config => $config, http => $http, %pruned);
	
	
};

#sub _update_myself_from {
#
#    my $self = shift; 
#    my $meta = $self->meta;
#    my %hash = @_;
#    foreach my $attribute ( $meta->get_all_attributes ) {
#        my $name = $attribute->name;
#        next unless  ( exists $hash{ $name } and defined $hash{ $name } );
#        $attribute->set_value( $hash{$name} );
#    }
#}
#
#sub _to_complete_hash {
#
#   return unless defined wantarray;
#   my $self = shift;
#   my $meta = $self->meta;
#   my %hash = map {( $_->name => $_->get_value )} (  $meta->get_all_attributes )  
#   wantarray ? %hash : \%hash;
#
#}


method _apiName_to_attributeName(Str $api_name) {

   state %api_hash;
   # We are going to be doing a bit of work,
   # so, if you don't care about the results, then
   # I'm just going to return.
   return unless defined wantarray;

   return $api_hash{$api_name} if %api_hash;
   my $meta = $self->meta;
   foreach my $attribute ( $meta->get_all_attributes ) { 

     my $attribute_name = $attribute->name;
     my $api_key = $attribute_name;

     $api_key = $attribute->APIAttributeName 
         if ( $attribute->does('WWW::Chargify::Meta::Attribute::Trait::APIAttribute')  
               and $attribute->has_APIAttributeName );
     
     $api_hash{$api_key} = $attribute_name
   }
   return $api_hash{$api_name};

}

method _to_hash_for_new_update() { return $self->_to_hash( excludeReadOnly => 1 ) }

method _to_hash( Bool :$excludeReadOnly=0 ) {

   return unless defined wantarray;

   my $meta = $self->meta;
   my %hash = ();
   foreach my $attribute (  $meta->get_all_attributes ) { 
    
     next unless ( $attribute->does('WWW::Chargify::Meta::Attribute::Trait::APIAttribute')
         and $attribute->isAPIAttribute ); 
         
     next if ( $excludeReadOnly and !$attribute->isAPIUpdatable );

     my $reader = $attribute->get_read_method;
     my $value = $self->$reader;
     next unless $value;

     my $key = $attribute->has_APIAttributeName 
               ?  $attribute->APIAttributeName
               :  $attribute->name;
     $hash{$key} = $value;
   }
   return wantarray ? %hash : \%hash;
}

}


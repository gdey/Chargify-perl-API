use Modern::Perl;
use MooseX::Declare;
use WWW::Chargify::Utils::DateTime;

role WWW::Chargify::Role::FromHash{

method _from_hash( $class: WWW::Chargify::Config :$config, 
                    WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){

use Data::Dumper;
	# Expect %args to have the following:
	#  hash => A hash ref containing the values to from the new object with.
	#  overrides => Overrides for those values.
	#  http => a WWW::Chargify::HTTP object.
	#  config => a WWW::Chargify::Config object.
	my %pruned = map  { $_ => $hash->{$_}   } 
               grep { defined $hash->{$_} } 
               keys %{$hash};

  say 'Pruned: '.Dumper(\%pruned);
  $pruned{$_} = $overrides->{$_} foreach keys %{$overrides};
  say 'Pruned: '.Dumper(\%pruned);

	return $class->new(config => $config, http => $http, %pruned);
	
	
};

method _to_hash_for_new_update() { return $self->_to_hash( excludeReadOnly => 1 ) }

method _to_hash( Bool :$excludeReadOnly=0 ) {

   return unless defined wantarray;

   my $meta = $self->meta;
   my %hash = ();
   foreach my $attribute ( map { $meta->get_attribute($_) } sort $meta->get_attribute_list ) { 
    
      next unless ( $attribute->does('WWW::Chargify::Meta::Attribute::Trait::APIAttribute')
         and $attribute->isAPIAttribute ); 

      if ( $attribute->does('WWW::Chargify::Meta::Attribute::Trait::APIAttribute')
         and $attribute->isAPIAttribute ) {

         my $key;
         if( $attribute->has_APIAttributeName ){
            $key = $attribute->APIAttributeName;
         } else {
            $key = $attribute->name;
         };

         next if ( $excludeReadOnly and !$attribute->isAPIUpdatable );
         my $reader = $attribute->get_read_method;
         $hash{$key} = $self->$reader;
      }
   }
   return wantarray ? %hash : \%hash;
}

}


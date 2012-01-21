package WWW::Chargify::Role::FromHash;
use Moose::Role;
use 5.010_000;
use feature ();
use UNIVERSAL;

use WWW::Chargify::Utils::DateTime;

#role WWW::Chargify::Role::FromHash{

#method _from_hash( $class: WWW::Chargify::Config :$config, 
#                    WWW::Chargify::HTTP :$http, HashRef :$hash, HashRef :$overrides = {} ){

sub _from_hash {

  my ($class, %args) = @_;
  my $http = $args{http}     || confess "the http object is required.  ";
  my $config = $args{config} || confess "the config object is required.";
  my $hash = $args{hash}     || confess "hash is required.";
  my $overrides = $args{overrides} || {};


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

#method _apiName_to_attributeName(Str $api_name) {
sub _apiName_to_attributeName{

   state %api_hash;

   # We are going to be doing a bit of work,
   # so, if you don't care about the results, then
   # I'm just going to return.
   return unless defined wantarray;

   my ($self, $api_name) = @_;
   confess "api_name is required." unless defined $api_name;

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

#method _to_hash_for_new_update() { return $self->_to_hash( excludeReadOnly => 1 ) }
sub _to_hash_for_new_update() { my $self = shift; return $self->_to_hash( excludeReadOnly => 1 ) }

#method _to_hash( Bool :$excludeReadOnly=0 ) {
sub _to_hash{

   my ($self, %args) = @_;
   my $excludeReadOnly = $args{excludeReadOnly} || 0;

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
     if( UNIVERSAL::isa( $value , "DateTime" ) ) {
         $hash{$key} = "$value";
     }

     $hash{$key} = $value;
   }
   return wantarray ? %hash : \%hash;
}

1;


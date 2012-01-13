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

}


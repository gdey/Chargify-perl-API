use Modern::Perl;
use MooseX::Declare;

role WWW::Chargify::Role::List {

   requires '_from_hash';
   requires '_hash_key';
   requires '_resource_key';

   method list ( $class: WWW::Chargify::HTTP :$http, HashRef :$options? ) {

      return unless defined wantarray;

      my $config = $http->config;
      my $hash_key = $class->_hash_key;
      my $resource_key = $class->_resource_key;

      my ($objects, $response) = $http->get($resource_key, $options);

      my @objects = map { $class->_from_hash( config => $config, http => $http, hash => $_->{$hash_key} ) }
      @{$objects};

      wantarray ? @objects : \@objects;

   }

};

1;

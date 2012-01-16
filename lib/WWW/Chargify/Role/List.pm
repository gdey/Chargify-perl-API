use Modern::Perl;
use MooseX::Declare;

role WWW::Chargify::Role::List {

   requires '_from_hash';
   requires '_hash_key';
   requires '_resource_key';

   method list ( $class: WWW::Chargify::HTTP :$http, HashRef :$options? ) {

      my $config = $http->config;
      my $hash_key = $class->_hash_key;
      my $resource_key = $class->_resource_key;

      $resource_key .='?'.$http->filter_string($options) if $options;

      say "Resource key: $resource_key";
      my ($objects, $response) = $http->get($resource_key);

      use Data::Dumper;
      say 'Body is:'.Dumper( $objects );

      return map { $class->_from_hash( config => $config, http => $http, hash => $_->{$hash_key} ) }
      @{$objects};

   }

};

1;

use Modern::Perl;
use MooseX::Declare;

role WWW::Chargify::Role::Find {

   requires '_from_hash';
   requires '_hash_key';
   requires '_resource_key';

   method _find_by ( $class: WWW::Chargify::HTTP :$http, ArrayRef :$params  ){

      my $config = $http->config;
      my $hash_key = $class->_hash_key;
      my $resource_key = $class->_resource_key;
      my ($object, $response) = $http->get($resource_key => @{$params});
      return $class->_from_hash( config => $config, http => $http, hash => $object->{$hash_key} ) ;
   }

   method find_by_id ( $class: WWW::Chargify::HTTP :$http, Num :$id ) {
      return $class->_find_by( http => $http, params => [$id] );
   }


};


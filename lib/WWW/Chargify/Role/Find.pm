package WWW::Chargify::Role::Find;
use Moose::Role;

requires '_from_hash';
requires '_hash_key';
requires '_resource_key';

#method _find_by ( $class: WWW::Chargify::HTTP :$http, ArrayRef :$params  ){
sub _find_by {

   my ($class, %args)  = @_;
   my $http = $args{http} || confess 'http is required.';
   my $params = $args{params} || confess 'params is required.';
   my $config = $http->config;
   my $hash_key = $class->_hash_key;
   my $resource_key = $class->_resource_key;
   my ($object, $response) = $http->get($resource_key => @{$params});
   return $class->_from_hash( config => $config, http => $http, hash => $object->{$hash_key} ) ;
}

#method find_by_id ( $class: WWW::Chargify::HTTP :$http, Num :$id ) {
sub find_by_id {
    my ($class, %args)  = @_;
    my $http = $args{http} || confess 'http is required.';
    my $id = $args{id} || confess 'id is required.';

   return $class->_find_by( http => $http, params => [$id] );
}

1;

package WWW::Chargify::Role::List;
use Moose::Role;

   requires '_from_hash';
   requires '_hash_key';
   requires '_resource_key';

   #method list ( $class: WWW::Chargify::HTTP :$http, HashRef :$options? ) {
   sub list {

      return unless defined wantarray;

      my ($class, %args) = @_;

      my $http = $args{http} || confess "http is required.";
      my $options = $args{options};

      my $config = $http->config;
      my $hash_key = $class->_hash_key;
      my $resource_key = $class->_resource_key;

      my ($objects, $response) = $http->get($resource_key, $options);

      my @objects = map { $class->_from_hash( config => $config, http => $http, hash => $_->{$hash_key} ) }
      @{$objects};

      wantarray ? @objects : \@objects;

   }

1;

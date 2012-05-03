package WWW::Chargify::Tests::Base;

use v5.10.0;
use strict;
use base qw( Test::Class );
use Test::More;
use WWW::Chargify;

sub __setup__ : Test(setup) {


}

sub _chargify {
   
   my ($self,%args) = @_;
   return WWW::Chargify->new(
      subdomain => $args{subdomain} || $ENV{CHARGIFY_SUBDOMAIN} || $ENV{SUBDOMAIN},
      apiKey => $args{apikey} || $ENV{CHARGIFY_APIKEY} || $ENV{APIKEY}
   );

}

sub __setup_chargify : Test(setup) {
    my $self = shift;
    unless( $ENV{CHARGIFY_SUBDOMAIN} && $ENV{CHARGIFY_APIKEY} ){

       note("CHARGIFY_SUBDOMAIN, and CHARGIFY_APIKEY variables are required to run test against the Chargify Webservice.");
       return  $self->SKIP_CLASS('Required Chargify Information not provided.');
       
   }
   my $chargify = $self->_chargify();
   $self->{chargify} = $chargify;
}

1;

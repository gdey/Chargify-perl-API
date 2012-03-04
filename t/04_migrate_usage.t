#!/usr/bin/perl
#
# Simple test case that migrates
# usage from one type of account over to another 
#
#
use strict;
use Moose;
use MooseX::Params::Validate;
use Test::Exception;
use Date::Format;
use Log::Log4perl;
use List::Util qw(first);
use Test::More;
no warnings;

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  CODE SAMPLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

BEGIN{
  use Test::More;
  use Test::Exception;

  unless( $ENV{CHARGIFY_SUBDOMAIN} && $ENV{CHARGIFY_APIKEY} ){
     note("NEEDED VARIABLES NOT DEFINED. THIS DOES NOT CHECK FOR ALL VARIABLES, THIS NEEDS TO BE FIX. SKIPPING FOR NOW. PLEASE look at the source for the correct ENV VARIABLES");
     plan skip_all => "Can not run tests without Chargify information.";

  }
  use_ok("WWW::Chargify");
  use_ok("WWW::Chargify::Subscription");
  use_ok("WWW::Chargify::Customer");
  use_ok("WWW::Chargify::Product");
}

#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  VARIABLES  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
my $account;
my $chargify;
my @components;
my $component;
my $original;
my $new_component;
my $new_product;
my $usage;
my $userid =  $ENV{TESTUSER_COMPONENT};

my $start_component;
my $start_product;

my @products    = split(" ",$ENV{TEST_COMPONENT_PRODUCTS});
my $tmp         = "\(" . join("|",@products) . "\)";
my $prod_regexp = qr{$tmp};
my $component_regexp = qr{$ENV{TEST_COMPONENT_REGEX}};


my $loglevel = eval{ eval("\$Log::Log4perl::$ENV{DEBUG_LEVEL}") } || 
  $Log::Log4perl::DEBUG;


#
# Assign this method to the class
#
no strict 'refs';


#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-  TESTS  =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

$chargify = WWW::Chargify->new(  
                               subdomain  => $ENV{SUBDOMAIN},
                               apiKey     => $ENV{APIKEY},
                              );
$chargify->meta->add_method("switch_subscription", \&switch_subscription );

$chargify->logger->level( $loglevel );

$account = $chargify->find_customer_by_reference( $ENV{TESTUSER_COMPONENT} );

lives_ok { 
    my $sub  = first { $_->state eq "active" && $_->product->name =~ $prod_regexp } $account->subscriptions;
    my $orig_balance;

    @products   = grep { $_->name ne $sub->product->name } grep { $_->name =~ $prod_regexp } $sub->product->product_family->products ;

    foreach my $product ( @products )  { 
        # Get the subscription
        $sub = first { $_->state eq "active" && $_->product->name =~ $prod_regexp } $account->subscriptions;
        my $old_product = $sub->product->name;
        my $basic;
        ($basic = $old_product) =~ s/$component_regexp/$1/;
        my $old_component  = first { my $f=$_; $f->name =~ /$basic/  } $sub->components;

        $orig_balance = $sub->usage_for_component( component => $old_component );

        #
        # Get the new component
        my $new_product   = $product->name;
        my $new_type;
        ( $new_type = $new_product ) =~  s/$component_regexp/$1/;
        my $new_component = first { $_->name =~ $new_type } $sub->components;

        #
        # Switch the subscription
        $chargify->switch_subscription( subscription     => $sub,
                                        end_component    => $new_component->name,
                                        end_product      => $new_product,
                                        start_product    => $old_product,
                                        start_component  => $old_component->name,
                                      );

        my $nusage = $sub->usage_for_component( component => $new_component );
        is( $nusage->unit_balance, $orig_balance->unit_balance , sprintf("Found the matching balance of '%s' MB for '%s'",$nusage->unit_balance,$new_product));

    }

} "Lives Successfully";


done_testing();

sub determine_product
{
    my ($product) = @_;
    my $tmp;
    ( $tmp =  $product ) =~ s/^(.*)\b$ENV{TEST_COMPONENT_PATTERN}\b(.*)$/$1$ENV{TEST_COMPONENT_NEWPATTERN}$2/; 
    return $tmp;
}


## @desc Will switch products and components 
#
sub switch_subscription
{
    my ($self,%args)     = validated_hash
                           (\@_, 
                            subscription    => { isa => 'WWW::Chargify::Subscription' },
                            start_component => { isa => 'Str'},
                            end_component   => { isa => 'Str'},
                            start_product => { isa => 'Str' },
                            end_product   => { isa => 'Str' },
                           );
    eval {
        $args{component} = first {  $_->name eq $args{start_component}  } $args{subscription}->components;
        my $ousage =  $args{subscription}->usage_for_component( component => $args{component} );

        my $ncomp = first { $_->name eq $args{end_component} } $args{subscription}->components;

        #
        # Subtract the first usage
        $args{subscription}->add_usage_for_component
                             (
                              component => $args{component},
                              quantity  => -1 * $ousage->unit_balance,
                              memo      => "Migrating Usage at " . DateTime->now(),
                             );

        #
        # First ensure that we have 0 Usage on the other plan
        
        my $nusage = $args{subscription}->usage_for_component( component => $ncomp );
        $args{subscription}->add_usage_for_component
                             (
                              component => $ncomp,
                              quantity  => -1 * $nusage->unit_balance,
                              memo      => "Zeroing out usage at " . DateTime->now(),
                             );
       
        #
        # Add the new usage
        $args{subscription}->add_usage_for_component
                             ( component => $ncomp ,
                               quantity  => $ousage->unit_balance,
                               memo      => "Added on " . DateTime->now(),
                             );

        my $nprod = first { $_->name eq $args{end_product} }  $args{subscription}->product->product_family->products;
        $args{subscription}->product( $nprod );
        
        $args{subscription}->save

    } ;
    if( $@ ){ 
        die "Couldn't switch subscription: $@";
    }

    print "";
}

## @desc 
#
sub get_component_name
{
    my ($chargify) = @_;
    my $original = s/^(.*)\b$ENV{TEST_COMPONENT_PATTERN}\b(.*)$/$1$ENV{TEST_COMPONENT_NEWPATTERN}$2/;
}

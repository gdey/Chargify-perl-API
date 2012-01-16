#!/usr/bin/perl

use strict;
use warnings;
use lib '../lib';
use lib 'lib';
use WWW::Chargify;
use Data::Dumper;
use v5.10.0;
use feature ":5.10";
use WWW::Chargify::Subscription;


my $chargify = WWW::Chargify->new( subdomain => 'trimid-com', apiKey => 'W4kRiuLMQOhgemu9FOR4' );

#my ($prod1, @products) = $chargify->products;
#my ($pd1) = $prod1->product_family->products;
#say Dumper( $pd1 );

#say Dumper($chargify->find_product_by( id => 79727 ));
#say Dumper($chargify->find_product_by( handle => 'anonymizer-universal-lite' ));
#say Dumper($chargify->product_families);
#say Dumper($chargify->product_families);
#say Dumper($chargify->find_product_family_by_id(20414));
#say Dumper( WWW::Chargify::Subscription->list( http => $chargify->http ) );
say Dumper( WWW::Chargify::CreditCard->new( 
     http => $chargify->http, 
     config => $chargify->config,
     payment_profile_id => 'value',
     card_type => 'value',
     first_name => 'value',
     last_name => 'value',
     masked_card_number => 'xxx-xxx-xxx-2345',
     id => 1, 
     expiration_month => 1,
     expiration_year =>  2015,
     customer_id => '1' )->_to_hash_for_new_update() );





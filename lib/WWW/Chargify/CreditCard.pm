use Modern::Perl;
use MooseX::Declare;

class WWW::Chargify::CreditCard {

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';

has id => (is => 'ro', isa => 'Str');
has payment_profile_id => (is => 'ro', isa => 'Str' );
has card_type => ( is => 'ro', isa => 'Str' );
has expiration_month => ( is => 'ro', isa => 'Num' );
has expiration_year => ( is => 'ro', isa => 'Num' );
has first_name => ( is => 'ro', isa => 'Str' );
has last_name => ( is => 'ro', isa => 'Str' );
has masked_card_number => ( is => 'ro', isa => 'Str' );
has customer_id => ( is => 'ro', isa => 'Str' );

sub _hash_key { 'credit_card' };

}


use Modern::Perl;
use MooseX::Declare;
use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
 

class WWW::Chargify::CreditCard {

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';

has [qw[ 
         payment_profile_id 
         card_type
         first_name
         last_name
         masked_card_number ]] =>
    ( 
        traits => [qw/Chargify::APIAttribute/],
        is => 'ro',
        isa => 'Str',
        required => 1,
    );


has id => 
    ( 
        traits => [qw/Chargify::APIAttribute/],
        is => 'ro', 
        isa => 'Num',
        required => 1,
        isAPIUpdatable => 0,

    );


has [qw[ expiration_month expiration_year ]] => 
    ( 
        traits => [qw/Chargify::APIAttribute/],
        is => 'ro', 
        isa => 'Num',
        required => 1,
    );

has customer_id => ( is => 'ro', isa => 'Str' );

sub _hash_key { 'credit_card' };

}


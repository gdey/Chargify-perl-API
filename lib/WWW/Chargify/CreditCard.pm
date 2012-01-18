use Modern::Perl;
use MooseX::Declare;
 

class WWW::Chargify::CreditCard {

   use WWW::Chargify;
   use WWW::Chargify::Customer;
   use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
   
   with 'WWW::Chargify::Role::Config';
   with 'WWW::Chargify::Role::HTTP';
   with 'WWW::Chargify::Role::FromHash';
   
   has payment_profile_id => (
           is => 'ro',
           isa => 'Str',
   );
   
   has masked_card_number => (
           is => 'ro',
           isa => 'Str',
   );
   
   has customer_id => ( is => 'ro', isa => 'Str' );
   
   has id => ( 
           is => 'ro', 
           isa => 'Num',
           predicate => 'has_id',
   );
   
   
   has [qw[ 
            first_name
            last_name
            full_number
            cvv
            card_type
            last_four
            vault_token
            customer_vault_token
            current_vault
   
            billing_address
            billing_address2
            billing_city
            billing_state
            billing_zip
            billing_country
   
       ]] => ( 
           traits => [qw/Chargify::APIAttribute/],
           is => 'rw',
           isa => 'Str',
       );
   
   has [qw[ expiration_month expiration_year ]] => ( 
           traits => [qw/Chargify::APIAttribute/],
           is => 'rw', 
           isa => 'Num',
       );
   
   
   sub _hash_key { 'credit_card' };
   
   method customer { WWW::Chargify::Customer->find_by_id( http => $self->http, id => $self->customer_id ) }

}


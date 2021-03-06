package WWW::Chargify::CreditCard;

BEGIN {
    use Moose;
    use Moose::Util::TypeConstraints;
    subtype CreditCardAttributeSet => as 'HashRef';
    coerce 'CreditCardAttributeSet' => from 'WWW::Chargify::CreditCard' => via {
        my $obj = $_;
        my @keys = qw( first_name last_name full_number expiration_month
                       expiration_year cvv billing_address billing_city
                       billing_state billing_zip billing_country
                       vault_token customer_vault_token current_vault
                       last_four card_type );

        my %tmp = map { $_ => $obj->{$_} } grep { defined $obj->{$_} } @keys;
        \%tmp;
    };
};
no warnings qw/uninitialized/;

#class WWW::Chargify::CreditCard {

use WWW::Chargify;
use WWW::Chargify::Customer;
use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
use DateTime;
use namespace::autoclean;



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
        clearer => 'clear_id'
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
sub customer { my $self = shift;  WWW::Chargify::Customer->find_by_id( http => $self->http, id => $self->customer_id ) }

sub expire_date {
   my $self = shift;
   return DateTime->new(
      year => $self->expiration_year,
      month => $self->expiration_month
   );
}
sub is_expired {
   my $self = shift;
   return DateTime->compare( DateTime->now, $self->expire_date ) == 1;
}


#}
1;


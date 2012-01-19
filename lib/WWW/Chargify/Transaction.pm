package WWW::Chargify::Transaction;
use Moose;
use WWW::Chargify::CreditCard;
use Moose::Util::TypeConstraints;
use WWW::Chargify::Utils::DateTime;
use WWW::Chargify::Utils::Bool;

with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash';
with 'WWW::Chargify::Role::List'; 
with 'WWW::Chargify::Role::Find';


has id => ( is => 'ro', isa => 'Num');
has transaction_type => (
      is => 'ro',
      isa => enum([qw[ charge refund payment credit payment_authorization info adjustment ]])
);
has amount_in_cents => ( is => 'ro', isa => 'Num' );
has created_at => ( is => 'ro', isa => 'DateTime', coerce => 1);
has ending_balance_in_cents => ( is => 'ro', isa => 'Num' );
has memo => (is => 'ro', isa => 'Str' );
has subscription_id => ( is => 'ro', isa => 'Num' );
has subscription => ( is => 'ro', init_arg => undef, builder => '_build_subscription', isa => 'WWW::Chargify::Subscription', lazy => 1 );
has product_id => ( is => 'ro', isa => 'Num' );
has product => ( is => 'ro', init_arg => undef, builder => '_build_product', isa => 'WWW::Chargify::Product' , lazy => 1);
has success => ( is => 'ro', isa => 'Bool', coerce =>  1);

sub _hash_key     { 'transaction' };
sub _resource_key { 'transactions' };

sub _build_subscription {
   my ($self) = @_;
   return WWW::Chargify::Subscription->find_by_id( http => $self->http, id => $self->subscription_id );
}

sub _build_product {
   my ($self) = @_;
   return WWW::Chargify::Product->find_by_id( http => $self->http, id => $self->product_id );
}

#around list ( $class: WWW::Chargify::HTTP :$http, HashRef :$options? ) {
around list => sub{ 

    my ($class, %args) = @_;
    my $http = $args{http} || confess 'http is required.';
    my $options = $args{options};


    if( $options and ( exists $options->{since_date} or exists $options->{until_date} ){
          $options->{since_date} = $options->{since_date}->strftime('%F')
             if( exists $options->{since_date} );
          $options->{until_date} = $options->{until_date}->strftime('%F')
             if( exists $options->{until_date} );
    }

    $orig->($class, http => $http, $options? (options => $options) : () );
}

1;


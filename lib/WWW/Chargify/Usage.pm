package WWW::Chargify::Usage;
use Moose;
use WWW::Chargify::Subscription;
use WWW::Chargify::Component;
use WWW::Chargify::Meta::Attribute::Trait::APIAttribute;



has id             => ( is  => 'ro', 
                        isa => 'Num' , 
                        predicate => "has_id",
                      );

has unit_balance   => ( is => 'rw',
                        isa => 'Int',
                      );

has name           => ( is => 'rw',
                        isa => 'Str'
                      );

has subscription   => ( is  => 'rw',
                        isa => 'WWW::Chargify::Subscription'
                      );

has kind           => ( is => 'rw',
                        isa => 'Str'
                      );

has component      => ( is  => 'rw',
                        isa => 'WWW::Chargify::Component'
                      );
with 'WWW::Chargify::Role::Config';
with 'WWW::Chargify::Role::HTTP';
with 'WWW::Chargify::Role::FromHash'; 

# sub _hash_key     { 'usage' };
# sub _resource_key { 'usages' };

1;

package WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
use Moose::Role;
 
has isAPIAttribute => (
    is        => 'rw',
    isa       => 'Bool',
    default   => 1,
);

has APIAttributeName => (
   is  => 'rw',
   isa => 'Str',
   predicate => 'has_APIAttributeName',
);

has isAPIUpdatable => (
   is => 'rw',
   isa => 'Bool',
   default => 1,
);



package Moose::Meta::Attribute::Custom::Trait::Chargify::APIAttribute;

sub register_implementation {'WWW::Chargify::Meta::Attribute::Trait::APIAttribute'};

1;

package WWW::Chargify::Meta::Attribute::Trait::APIAttribute;
use Moose::Role;
 
has label => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_label',
);

package Moose::Meta::Attribute::Custom::Trait::Chargify::APIAttribute;
sub register_implementation {'WWW::Chargify::Meta::Attribute::Trait::APIAttribute'}

1;

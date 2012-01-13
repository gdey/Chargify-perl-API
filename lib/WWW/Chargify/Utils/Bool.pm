package WWW::Chargify::Utils::Bool;
use version 0.77; $VERSION = version->declare('v0.0.1');
use Moose;
use Moose::Util::TypeConstraints;
use JSON::XS;

 class_type JSONBoolean => { class => 'JSON::XS::Boolean' };
 coerce 'Bool' => from 'JSONBoolean' => via { JSON::XS::is_bool $_; };

1;


package WWW::Chargify::Utils::DateTime;
use version 0.77; $VERSION = version->declare('v0.0.1');
use Moose;
use Moose::Util::TypeConstraints;
use DateTime::Format::W3CDTF;

 coerce 'DateTime' => from 'Str' => via { 
       DateTime::Format::W3CDTF->new->parse_datetime($_);
 };

1;



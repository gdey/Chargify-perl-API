package WWW::Chargify::Utils::DateTime;
#use version 0.77; 
our $VERSION = version->declare('v0.0.1');
use Moose;
use Moose::Util::TypeConstraints;
use Date::Parse;
use DateTime::Format::W3CDTF;

 coerce 'DateTime' => from 'Str' => via { 
     my $retval;
     eval {
         $retval = DateTime::Format::W3CDTF->new->parse_datetime($_);
         return $retval;
     };
     
     # Try again with the other format
     my $tmp = Date::Parse::str2time( $_ );
     DateTime->from_epoch( epoch => $tmp );
 };

1;



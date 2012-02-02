package WWW::Chargify::Role::JsonWrap;
use JSON ();
use Exporter;

use vars qw(@EXPORT @ISA);

@EXPORT = qw(decode_json
              encode_json
            );
@ISA = qw(Exporter);


sub decode_json($) 
{ 
    my $obj = JSON::decode_json( $_[0] );
    return _replace_booleans( $obj , 6 );
}


sub encode_json($) {
    goto & JSON::encode_json;
}

sub _replace_booleans {
    my ($self,$maxdepth) = @_;
    return $self if ( $maxdepth <= 0 );
    if( ref $self eq "HASH"  ) {
        foreach my $key ( keys %{$self} ) {
            $self->{$key} = _replace_booleans( $self->{$key}, $maxdepth - 1);
        }
    } elsif( ref $self eq "ARRAY" ) {
        for( my $i = 0; $i <= $#{$self} ; $i ++ ) {
            $self->[$i] = _replace_booleans( $self->[$i], $maxdepth - 1 );
        }
    } elsif( ref $self eq "JSON::XS::Boolean" ) {
        return ( $self ? 1 : 0 );
    }
    return $self;
}

1;

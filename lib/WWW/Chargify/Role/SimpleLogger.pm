package WWW::Chargify::Role::SimpleLogger;

use v5.10.0;
use Moose::Role;
use MooseX::Types;
use Moose::Util::TypeConstraints;
use Log::Log4perl;
use strict;
our $_LOGGER;

subtype 'ValidLogger'
  => as 'Object'
  => where {
      if( UNIVERSAL::can( $_, "debug" ) &&
          UNIVERSAL::can( $_, "info"  ) &&
          UNIVERSAL::can( $_, "error" ) &&
          UNIVERSAL::can( $_, "fatal" ) &&
          UNIVERSAL::can( $_, "warn"  ) ) {
          return 1;
      } else {
          return 0;
      }
      return 1;
  }
  => message { "$_  is not a valid ValidLogger" };


has logger => ( is      => 'rw', 
                isa     => "ValidLogger",
                lazy    => 0,
                builder => "_build_logger"
              ); 
##
#
#
sub _build_logger
{
    my $log_conf = q|
log4perl.category = INFO, BasicPrintScreen
log4perl.appender.Logfile = Log::Log4perl::Appender::File
log4perl.PatternLayout.cspec.U = sub { return "\t" }

log4perl.appender.BasicPrintScreen  = Log::Log4perl::Appender::Screen
log4perl.appender.BasicPrintScreen.stderr = 0
log4perl.appender.BasicPrintScreen.layout = Log::Log4perl::Layout::PatternLayout
log4perl.appender.BasicPrintScreen.ConversionPattern = %n
log4perl.logger.main = ERROR
|;
    my $tmplogger;
    #$DB::signal = 1;
    if ( ! defined __PACKAGE__->_get_logger() ) {
        eval { 
            Log::Log4perl->init_once(\$log_conf);
            $tmplogger = Log::Log4perl->get_logger('BasicPrintScreen');
            $tmplogger->level( $Log::Log4perl::INFO  );
        }; 
        if ( $@ ) {
            $tmplogger = Log::Log4perl->easy_init($Log::Log4perl::ERROR);
        } else {
            $tmplogger->level( $Log::Log4perl::INFO );
        }
        __PACKAGE__->_set_logger( $tmplogger );
    } else {
        $tmplogger = __PACKAGE__->_get_logger();
    }
    return $tmplogger;
}
sub debug { _get_logger()->debug( @_ ) }
sub error { _get_logger()->error( @_ ) }
sub warn  { _get_logger()->warn( @_ )  }
sub fatal { _get_logger()->fatal( @_ ) };
sub info  { _get_logger()->info( @_ )  };
sub logger{ _get_logger() };

sub _get_logger
{
    return $_LOGGER;
}
sub _set_logger
{
    my ($class,$logger) = @_;
    $_LOGGER = $logger;
}
1;

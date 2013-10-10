package Audio::PortAudio::FFI;
use strict;
use warnings;

=head1 NAME

Audio::PortAudio::FFI - PortAudio bindings via FFI::Raw

=head1 SYNOPSIS

  # Should work the same as Audio::PortAudio

=cut

use v5.14;
use FFI::Raw;

use constant {
  PA_LIBRARY  => 'libportaudio.so.2',

  PA_ERROR => FFI::Raw::int,
};



# Function signatures from libportaudio2
# name => [ return type, arg1, arg2, ... ]
my %extern = (
  Pa_GetVersion => [
    FFI::Raw::int,
  ],
  Pa_GetVersionText => [
    FFI::Raw::str,
  ],
  Pa_GetErrorText => [
    FFI::Raw::str,
    PA_ERROR,
  ],
  Pa_Initialize => [
    PA_ERROR,
  ],
  Pa_Terminate => [
    PA_ERROR,
  ],

);

my %ffi = ();
{
  no strict 'refs';
  for my $name ( keys %extern ){
    my $type = shift $extern{$name};

    $ffi{$name} = FFI::Raw->new(
      PA_LIBRARY,
      $name, $type,
      @{ $extern{$name} }
    );

    *{ __PACKAGE__ .'::'. lc($name) } =
    *{ __PACKAGE__ .'::'. $name     } = sub {
      return $ffi{$name}->call(@_);
    };
  }
}







1;

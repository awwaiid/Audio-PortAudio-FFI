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
my %funcs = (
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

sub _build_ffi_wrappers {
  my $funcs = shift;
  
  no strict 'refs';
  for my $name ( keys %$funcs ){
    my $type = shift $funcs->{$name};

    my $ffi = FFI::Raw->new(
      PA_LIBRARY,
      $name, $type,
      @{ $funcs->{$name} }
    );

    *{ __PACKAGE__ .'::'. lc($name) } =
    *{ __PACKAGE__ .'::'. $name     } = sub {
      return $ffi->call(@_);
    };
  }
}

_build_ffi_wrappers( \%funcs );




1;

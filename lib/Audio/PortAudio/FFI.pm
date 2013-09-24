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

my $pa_getversion = FFI::Raw->new(
  'libportaudio.so',
  'Pa_GetVersion',
  FFI::Raw::int # return value
);

sub pa_getversion {
  $pa_getversion->();
}

1;

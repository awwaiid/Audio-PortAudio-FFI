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
use Config;

use constant long  => FFI::Raw::int;
use constant ulong => FFI::Raw::uint;
# FFI::Raw 1.04 lacks a long type, but internally it
# is explicitly 32 bits for its integer types. Not ideal?

use constant {
  PA_LIBRARY  => 'libportaudio.so.2',

  # Taking a page from ruby-portaudio with typedefs
  # and constants 

  PA_ERROR     => FFI::Raw::int,
  PA_NO_ERROR  => FFI::Raw::int,
  
  PA_DEVICE_INDEX       => FFI::Raw::int,
  PA_HOST_API_TYPE_ID   => FFI::Raw::int,
  PA_HOST_API_INDEX     => FFI::Raw::int,
  PA_NO_DEVICE          => ( 2 ** $Config{longsize} ) - 1,

  PA_TIME               => FFI::Raw::double,

  PA_SAMPLE_FORMAT      => ulong,
  PA_SAMPLE_FORMAT_MAP => {
    float32 => 0x00001,
    int32   => 0x00002,
    int24   => 0x00004,
    int16   => 0x00008,
    int8    => 0x00010,
    uint8   => 0x00020,
    custom  => 0x10000,
  },
  
  PA_NON_INTERLEAVED => 0x80000000,
  
  PA_FORMAT_IS_SUPPORTED => 0,
  
  PA_FRAMES_PER_BUFFER_UNSPECIFICED => 0,
  
  PA_STREAM_FLAGS     => ulong,
  PA_NO_FLAG          => 0,
  PA_CLIP_OFF         => 0x00000001,
  PA_DITHER_OFF       => 0x00000002,
  PA_NEVER_DROP_INPUT => 0x00000004,
  PA_PRIME_OUTPUT_BUFFERS_USING_STREAM_CALLBACK
                      => 0x00000008,
  PA_PLATFORM_SPECIFIC_FLAGS
                      => 0xFFFF0000,
  
  PA_STREAM_CALLBACK_FLAGS => ulong,
  PA_INPUT_UNDERFLOW  => 0x00000001,
  PA_INPUT_OVERFLOW   => 0x00000002,
  PA_OUTPUT_UNDERFLOW => 0x00000004,
  PA_OUTPUT_OVERFLOW  => 0x00000008,
  PA_PRIMING_OUTPUT   => 0x00000010,
  
  PA_STREAM_CALLBACK_RESULT => FFI::Raw::int,
  PA_CONTINUE => 0,
  PA_COMPLETE => 1,
  PA_ABORT    => 2,
  
  PA_STREAM_CALLBACK          => FFI::Raw::ptr,
  PA_STREAM_FINISHED_CALLBACK => FFI::Raw::ptr,
  
};

#TODO: handle structs
# wrap up a struct definition reader that handles pack/unpack.
# see FFI::Raw::MemPtr


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
  
  Pa_GetHostApiCount => [
    PA_DEVICE_INDEX,
  ],
  Pa_GetDefaultHostApi => [
    PA_DEVICE_INDEX,
  ],
  Pa_GetHostApiInfo => [
    FFI::Raw::ptr,
    FFI::Raw::int,
  ],
  Pa_HostApiTypeIdToHostApiIndex => [
    PA_HOST_API_INDEX,
    PA_HOST_API_TYPE_ID,
  ],
  
  Pa_HostApiDeviceIndexToDeviceIndex => [
    PA_DEVICE_INDEX,
    PA_HOST_API_INDEX, FFI::Raw::int,
  ],
  Pa_GetLastHostErrorInfo => [
    FFI::Raw::ptr,
  ],
  Pa_GetDeviceCount => [
    PA_DEVICE_INDEX,
  ],
  Pa_GetDefaultInputDevice => [
    PA_DEVICE_INDEX,
  ],
  Pa_GetDefaultOutputDevice => [
    PA_DEVICE_INDEX,
  ],
  Pa_GetDeviceInfo => [
    FFI::Raw::ptr,
    PA_DEVICE_INDEX,
  ],
  
  Pa_IsFormatSupported => [
    PA_ERROR,
    FFI::Raw::ptr, FFI::Raw::ptr, FFI::Raw::double,
  ],
  
  Pa_OpenStream => [
    PA_ERROR,
    FFI::Raw::ptr, FFI::Raw::ptr, FFI::Raw::ptr, FFI::Raw::double, ulong, PA_STREAM_FLAGS, PA_STREAM_CALLBACK, FFI::Raw::ptr,
  ],
  Pa_OpenDefaultStream => [
    PA_ERROR,
    FFI::Raw::ptr, FFI::Raw::int, FFI::Raw::int, PA_SAMPLE_FORMAT, FFI::Raw::double, ulong, PA_STREAM_CALLBACK, FFI::Raw::ptr,
  ],
  Pa_CloseStream => [
    PA_ERROR,
    FFI::Raw::ptr,
  ],
  
  Pa_SetStreamFinishedCallback => [
    PA_ERROR,
    FFI::Raw::ptr, FFI::Raw::ptr,
  ],
  
  Pa_StartStream => [
    PA_ERROR,
    FFI::Raw::ptr,
  ],
  Pa_StopStream => [
    PA_ERROR,
    FFI::Raw::ptr,
  ],
  Pa_AbortStream => [
    PA_ERROR,
    FFI::Raw::ptr,
  ],
  
  Pa_IsStreamStopped => [
    PA_ERROR,
    FFI::Raw::ptr,
  ],
  Pa_IsStreamActive => [
    PA_ERROR,
    FFI::Raw::ptr,
  ],
  Pa_GetStreamInfo => [
    FFI::Raw::ptr,
    FFI::Raw::ptr,
  ],
  Pa_GetStreamTime => [
    PA_TIME,
    FFI::Raw::ptr,
  ],
  Pa_GetStreamCpuLoad => [
    FFI::Raw::double,
    FFI::Raw::ptr,
  ],
  
  Pa_ReadStream => [
    PA_ERROR,
    FFI::Raw::ptr, FFI::Raw::ptr, ulong,
  ],
  Pa_WriteStream => [
    PA_ERROR,
    FFI::Raw::ptr, FFI::Raw::ptr, ulong,
  ],

  Pa_GetStreamReadAvailable => [
    long,
    FFI::Raw::ptr,
  ],
  Pa_GetStreamWriteAvailable => [
    long,
    FFI::Raw::ptr,
  ],

  Pa_GetSampleSize => [
    PA_ERROR,
    ulong,
  ],
  Pa_Sleep => [
    FFI::Raw::void,
    long,
  ],
);

sub _build_ffi_wrappers {
  my $pkg   = shift;
  my $funcs = shift;
  
  no strict 'refs';
  for my $name ( keys %$funcs ){
    my $type = shift $funcs->{$name};

    my $ffi = FFI::Raw->new(
      PA_LIBRARY,
      $name, $type,
      @{ $funcs->{$name} }
    );

    *{ $pkg .'::'. lc($name) } =
    *{ $pkg .'::'. $name     } = sub {
      return $ffi->call(@_);
    };
  }
}

__PACKAGE__->_build_ffi_wrappers( \%funcs );




1;

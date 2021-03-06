package Audio::PortAudio::FFI;
use strict;
use warnings;

=head1 NAME

Audio::PortAudio::FFI - PortAudio bindings via FFI::Raw

=head1 SYNOPSIS

  # Should work the same as Audio::PortAudio

=cut

use v5.14;
use Config;

use FFI::Sweet;

use namespace::clean;

ffi_lib \'libportaudio.so.2';


use constant {
  # Taking a page from ruby-portaudio with typedefs
  # and constants

  PA_ERROR     => _int,
  PA_NO_ERROR  => _int,

  PA_DEVICE_INDEX       => _int,
  PA_HOST_API_TYPE_ID   => _int,
  PA_HOST_API_INDEX     => _int,
  PA_NO_DEVICE          => ( 2 ** $Config{longsize} ) - 1,

  PA_TIME               => _double,

  PA_SAMPLE_FORMAT      => _ulong,
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

  PA_STREAM_FLAGS     => _ulong,
  PA_NO_FLAG          => 0,
  PA_CLIP_OFF         => 0x00000001,
  PA_DITHER_OFF       => 0x00000002,
  PA_NEVER_DROP_INPUT => 0x00000004,
  PA_PRIME_OUTPUT_BUFFERS_USING_STREAM_CALLBACK
                      => 0x00000008,
  PA_PLATFORM_SPECIFIC_FLAGS
                      => 0xFFFF0000,

  PA_STREAM_CALLBACK_FLAGS => _ulong,
  PA_INPUT_UNDERFLOW  => 0x00000001,
  PA_INPUT_OVERFLOW   => 0x00000002,
  PA_OUTPUT_UNDERFLOW => 0x00000004,
  PA_OUTPUT_OVERFLOW  => 0x00000008,
  PA_PRIMING_OUTPUT   => 0x00000010,

  PA_STREAM_CALLBACK_RESULT => _int,
  PA_CONTINUE => 0,
  PA_COMPLETE => 1,
  PA_ABORT    => 2,

  PA_STREAM_CALLBACK          => _ptr,
  PA_STREAM_FINISHED_CALLBACK => _ptr,

};

#TODO: handle structs
# wrap up a struct definition reader that handles pack/unpack.
# see FFI::Raw::MemPtr

ffi_struct 'PaHostApiInfo' => (
  struct_version => 'i',
  type           => 'i',	# PA_HOST_API_TYPE_ID
  name           => 'p',
  device_count   => 'i',
  default_input_device   => 'i',	# PA_DEVICE_INDEX
  default_output_device  => 'i',	# PA_DEVICE_INDEX
);

ffi_struct 'PaHostErrorInfo' => (
  host_api_type => 'i',	# PA_HOST_API_TYPE_ID
  error_code    => 'l',
  error_text    => 'p',
);

ffi_struct 'PaDeviceInfo' => (
  struct_version => 'i',
  name           => 'p',
  host_api       => 'i',	# PA_HOST_API_INDEX
  max_input_channels          => 'i',
  max_output_channels         => 'i',
  default_low_input_latency   => 'd',	# PA_TIME
  default_low_output_latency  => 'd',	# PA_TIME
  default_high_input_latency  => 'd',	# PA_TIME
  default_high_output_latency => 'd',	# PA_TIME
  default_sample_rate         => 'd',
);

ffi_struct 'PaStreamParameters' => (
  device                    => 'i',	# PA_DEVICE_INDEX
  channel_count             => 'i',
  sample_format             => 'L',	# PA_SAMPLE_FORMAT
  suggested_latency         => 'd',	# PA_TIME
  host_specific_stream_info => 'x' . $Config{ptrsize},  #FIXME - opaque pointer handling
) => sub {
  #init method for this struct
  my $self = shift;
  $self->SUPER::init( @_ );
  
  #ruby has some code to magic the index from a Device passed in
  #should we just make the device class stringify to its index?
  
  #remap from symbolic formats to the bit vector expected
  if ( my $f = $self->{sample_format} ){
    if ( my $v = SAMPLE_FORMAT_MAP()->{$f} ){
      $self->{sample_format} = $v;
    }
  }

};

ffi_struct 'PaStreamInfo' => (
  struct_version => 'i',
  input_latency  => 'd',	# PA_TIME
  output_latency => 'd',	# PA_TIME
  sample_rate    => 'd',
);


# Function signatures from libportaudio2
attach_function 'Pa_GetVersion', undef, _int;
attach_function 'Pa_GetVersionText', undef, _str;
attach_function 'Pa_GetErrorText', [ PA_ERROR ], _str;
attach_function 'Pa_Initialize', undef, PA_ERROR;
attach_function 'Pa_Terminate', undef,  PA_ERROR;

attach_function 'Pa_GetHostApiCount', undef, PA_DEVICE_INDEX;
attach_function 'Pa_GetDefaultHostApi', undef, PA_DEVICE_INDEX;
attach_function 'Pa_GetHostApiInfo', [ _int ], _ptr;
attach_function 'Pa_HostApiTypeIdToHostApiIndex', [ PA_HOST_API_TYPE_ID ], PA_HOST_API_INDEX;
attach_function 'Pa_HostApiDeviceIndexToDeviceIndex', [ PA_HOST_API_INDEX, _int ], PA_DEVICE_INDEX;
attach_function 'Pa_GetLastHostErrorInfo', undef, _ptr;
attach_function 'Pa_GetDeviceCount', undef, PA_DEVICE_INDEX;
attach_function 'Pa_GetDefaultInputDevice', undef, PA_DEVICE_INDEX;
attach_function 'Pa_GetDefaultOutputDevice', undef, PA_DEVICE_INDEX;
attach_function 'Pa_GetDeviceInfo', [ PA_DEVICE_INDEX ], _ptr;
attach_function 'Pa_IsFormatSupported', [ _ptr, _ptr, _double ], PA_ERROR;

attach_function 'Pa_OpenStream', [ _ptr, _ptr, _ptr, _double, _ulong, PA_STREAM_FLAGS, PA_STREAM_CALLBACK, _ptr ], PA_ERROR;
attach_function 'Pa_OpenDefaultStream', [ _ptr, _int, _int, PA_SAMPLE_FORMAT, _double, _ulong, PA_STREAM_CALLBACK, _ptr ], PA_ERROR;
attach_function 'Pa_CloseStream', [ _ptr ], PA_ERROR;

attach_function 'Pa_SetStreamFinishedCallback', [ _ptr, _ptr ], PA_ERROR;

attach_function 'Pa_StartStream', [ _ptr ], PA_ERROR;
attach_function 'Pa_StopStream', [ _ptr ], PA_ERROR;
attach_function 'Pa_AbortStream', [ _ptr ], PA_ERROR;

attach_function 'Pa_IsStreamStopped', [ _ptr ], PA_ERROR;
attach_function 'Pa_IsStreamActive', [ _ptr ], PA_ERROR;
attach_function 'Pa_GetStreamInfo', [ _ptr ], _ptr;
attach_function 'Pa_GetStreamTime', [ _ptr ], PA_TIME;
attach_function 'Pa_GetStreamCpuLoad', [ _ptr ], _double;

attach_function 'Pa_ReadStream', [ _ptr, _ptr, _ulong ], PA_ERROR;
attach_function 'Pa_WriteStream', [ _ptr, _ptr, _ulong ], PA_ERROR;

attach_function 'Pa_GetStreamReadAvailable', [ _ptr ], _long;
attach_function 'Pa_GetStreamWriteAvailable', [ _ptr ], _long;

attach_function 'Pa_GetSampleSize', [ _ulong ], PA_ERROR;
attach_function 'Pa_Sleep', [ _long ], _void;


1;

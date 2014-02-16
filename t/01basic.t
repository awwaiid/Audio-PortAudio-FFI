
use strict;
use Test::More;


=pod

Tests from Audio::PortAudio. This is it, everything.  We want
to match API though so it's a start.

ok(Audio::PortAudio::version(),"version");
ok(Audio::PortAudio::version_text(),"version_text");

my $api = Audio::PortAudio::default_host_api();

my $device  = $api->default_output_device;

my $pi = 3.14159265358979323846;
my $sine = pack "f*", map { sin( $pi * $_ / 100 ) / 8 } 0 .. 399;

my $stream = $device->open_write_stream(
    {
        channel_count => 1,
    },
    44100,
    400,
    0
);
for (0 .. 400) {
    $stream->write($sine);
}
=cut

use_ok('Audio::PortAudio::FFI');

ok( Audio::PortAudio::FFI::Pa_GetVersion(),     'version' );
ok( Audio::PortAudio::FFI::Pa_GetVersionText(), 'version text' );

is(
  Audio::PortAudio::FFI::Pa_GetErrorText(0),    'Success',
  'error text'
);

Audio::PortAudio::FFI::Pa_Initialize();
use Devel::Dwarn; 
my $api_count = Audio::PortAudio::FFI::Pa_GetHostApiCount();
note( "Got $api_count host apis" );
for ( 0 .. ($api_count - 1) ){
  my $hostapi = new_ok( 'Audio::PortAudio::FFI::PaHostApiInfo' );
  my $p;
  ok ( $p = Audio::PortAudio::FFI::Pa_GetHostApiInfo($_), "Get Hostapi $_ info" );
  
  #~ my $m = FFI::Raw::MemPtr->new_from_ptr($p);
  #~ Dwarn $m->tostr;
  
  ok ( $hostapi->from_memptr( $p ), 'load hostapi struct' );
  Dwarn $hostapi;
}

Audio::PortAudio::FFI::Pa_Terminate();

done_testing();

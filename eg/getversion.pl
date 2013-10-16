#!/usr/bin/env perl

use strict;
use lib 'lib';
use Audio::PortAudio::FFI;

print "Version:      " . Audio::PortAudio::FFI::pa_getversion() . "\n";
print "Version Info: " . Audio::PortAudio::FFI::pa_getversiontext() . "\n";

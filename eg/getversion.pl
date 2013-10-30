#!/usr/bin/env perl

use strict;
use lib 'lib';
use Audio::PortAudio::FFI;

print "Version:      " . Audio::PortAudio::FFI::Pa_GetVersion() . "\n";
print "Version Info: " . Audio::PortAudio::FFI::Pa_GetVersionText() . "\n";

print "Sleeping 1 sec...\n";
Audio::PortAudio::FFI::Pa_Sleep(1_000);
print "\n";

print "Sleeping 70 sec (test call >65535 msec)...\n";
Audio::PortAudio::FFI::Pa_Sleep(70_000);
print "\n";
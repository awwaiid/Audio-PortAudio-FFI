package FFI::Raw::Sweet;

use warnings;
use strict;

use parent 'Exporter::Tiny';

use Carp;
use Sub::Name;
use FFI::Raw;


# Set up our exports
my @FFI_TYPES = qw( void int uint short ushort char uchar float double str ptr );

our @EXPORT      = qw( ffi_lib attach_function );
our @EXPORT_OK   = map { "_$_" } @FFI_TYPES;
our %EXPORT_TAGS = (
  core  => \@EXPORT,
  types => sub {
    
    # Copy the type constants from FFI::Raw so they can be imported, but rename
    for my $type ( @FFI_TYPES ){
      my $const = "_$type";      
      _install_sub( __PACKAGE__, $const, FFI::Raw->can($type) );
    }

    return map { "_$_" } @FFI_TYPES;
  }
);


# FIXME?  ruby's FFI supports building a list of libs to load
sub ffi_lib ($) {
  $^H{'FFI::Raw::Sweet/ffi_lib'} = shift;
}
# it also supports already-loaded libs and function visibility
# you know what i want to research FFI more, we could make this
# way better


sub attach_function ($$$) {
  my ( $name, $arg_types, $rv_type ) = @_;
  my $pkg = caller;

  my $ffi_lib = $^H{'FFI::Raw::Sweet/ffi_lib'};
  croak "ffi_lib must be defined in this scope" if ! $ffi_lib;

  $arg_types //= [];
  
  croak "Function name is required" if ! $name;
  croak "Return type is required for $name" if ! $rv_type;
  croak "Arg types must be an array reference for $name" if ! ref $arg_types;
  
  my $ffi = FFI::Raw->new(
    $ffi_lib,
    $name, $rv_type,
    @$arg_types
  );
  
  _install_sub( $pkg, $name,
    sub {
      return $ffi->call(@_);
    }
  );
}

sub _install_sub {
  my ( $pkg, $name, $code ) = @_;

  no strict 'refs';
  *{ $pkg .'::'. $name } = subname $name, $code;
}

package FFI::Raw::Sweet::Struct;

#design guesses:
#build classes that
# have accessors for each field
# know field order and type and build a pack() format
# have a to_memptr method for passing into FFI calls ( tricky: structs modified in place by call )
# have a from_memptr method to inflate from a returned pointer
# these may be internal and masked by magic?
# look at how ffi-raw-memptr is implemented


1;

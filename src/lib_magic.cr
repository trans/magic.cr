# Raw Crystal binding to libmagic.
#
# This `lib` maps directly to the C API declared by `magic.h`. Prefer the
# higher-level `Magic` wrapper for ordinary use; use `LibMagic` when you need
# an exact C function, raw constant, or custom ownership pattern.
@[Link("magic")]
lib LibMagic
  MAGIC_NONE             = 0x0000000
  MAGIC_DEBUG            = 0x0000001
  MAGIC_SYMLINK          = 0x0000002
  MAGIC_COMPRESS         = 0x0000004
  MAGIC_DEVICES          = 0x0000008
  MAGIC_MIME_TYPE        = 0x0000010
  MAGIC_CONTINUE         = 0x0000020
  MAGIC_CHECK            = 0x0000040
  MAGIC_PRESERVE_ATIME   = 0x0000080
  MAGIC_RAW              = 0x0000100
  MAGIC_ERROR            = 0x0000200
  MAGIC_MIME_ENCODING    = 0x0000400
  MAGIC_MIME             = 0x0000410
  MAGIC_APPLE            = 0x0000800
  MAGIC_EXTENSION        = 0x1000000
  MAGIC_COMPRESS_TRANSP  = 0x2000000
  MAGIC_NO_COMPRESS_FORK = 0x4000000
  MAGIC_NODESC           = 0x1000c10

  MAGIC_NO_CHECK_COMPRESS = 0x0001000
  MAGIC_NO_CHECK_TAR      = 0x0002000
  MAGIC_NO_CHECK_SOFT     = 0x0004000
  MAGIC_NO_CHECK_APPTYPE  = 0x0008000
  MAGIC_NO_CHECK_ELF      = 0x0010000
  MAGIC_NO_CHECK_TEXT     = 0x0020000
  MAGIC_NO_CHECK_CDF      = 0x0040000
  MAGIC_NO_CHECK_CSV      = 0x0080000
  MAGIC_NO_CHECK_TOKENS   = 0x0100000
  MAGIC_NO_CHECK_ENCODING = 0x0200000
  MAGIC_NO_CHECK_JSON     = 0x0400000
  MAGIC_NO_CHECK_SIMH     = 0x0800000

  MAGIC_NO_CHECK_BUILTIN = 0x0ffb000

  MAGIC_NO_CHECK_ASCII   = 0x0020000
  MAGIC_NO_CHECK_FORTRAN =  0x000000
  MAGIC_NO_CHECK_TROFF   =  0x000000

  MAGIC_PARAM_INDIR_MAX      = 0
  MAGIC_PARAM_NAME_MAX       = 1
  MAGIC_PARAM_ELF_PHNUM_MAX  = 2
  MAGIC_PARAM_ELF_SHNUM_MAX  = 3
  MAGIC_PARAM_ELF_NOTES_MAX  = 4
  MAGIC_PARAM_REGEX_MAX      = 5
  MAGIC_PARAM_BYTES_MAX      = 6
  MAGIC_PARAM_ENCODING_MAX   = 7
  MAGIC_PARAM_ELF_SHSIZE_MAX = 8
  MAGIC_PARAM_MAGWARN_MAX    = 9

  # Opaque libmagic handle type returned by `magic_open`.
  alias Handle = Void*

  # Allocates a new libmagic handle with the given flag bitmask.
  fun magic_open(flags : LibC::Int) : Handle

  # Releases a handle returned by `magic_open`.
  fun magic_close(cookie : Handle) : Void

  # Resolves the path libmagic would use for a magic database.
  fun magic_getpath(magicfile : LibC::Char*, action : LibC::Int) : LibC::Char*

  # Identifies the file at *filename*.
  fun magic_file(cookie : Handle, filename : LibC::Char*) : LibC::Char*

  # Identifies the data available from an open file descriptor.
  fun magic_descriptor(cookie : Handle, fd : LibC::Int) : LibC::Char*

  # Identifies the given memory buffer.
  fun magic_buffer(cookie : Handle, buffer : Void*, length : LibC::SizeT) : LibC::Char*

  # Returns the last error message for *cookie*, or null if none is available.
  fun magic_error(cookie : Handle) : LibC::Char*

  # Returns the current flag bitmask for *cookie*.
  fun magic_getflags(cookie : Handle) : LibC::Int

  # Replaces the current flag bitmask for *cookie*.
  fun magic_setflags(cookie : Handle, flags : LibC::Int) : LibC::Int

  # Returns the linked libmagic version number.
  fun magic_version : LibC::Int

  # Loads the default database or the colon-separated database path list.
  fun magic_load(cookie : Handle, filename : LibC::Char*) : LibC::Int

  # Loads one or more magic databases from memory buffers.
  fun magic_load_buffers(cookie : Handle, buffers : Void**, sizes : LibC::SizeT*, nbuffers : LibC::SizeT) : LibC::Int

  # Compiles the default database or the colon-separated database path list.
  fun magic_compile(cookie : Handle, filename : LibC::Char*) : LibC::Int

  # Checks the default database or the colon-separated database path list.
  fun magic_check(cookie : Handle, filename : LibC::Char*) : LibC::Int

  # Prints database entries in a human-readable format.
  fun magic_list(cookie : Handle, filename : LibC::Char*) : LibC::Int

  # Returns the last operating system errno reported by libmagic.
  fun magic_errno(cookie : Handle) : LibC::Int

  # Sets a numeric libmagic resource limit.
  fun magic_setparam(cookie : Handle, param : LibC::Int, value : Void*) : LibC::Int

  # Reads a numeric libmagic resource limit.
  fun magic_getparam(cookie : Handle, param : LibC::Int, value : Void*) : LibC::Int

  # Returns the maximum supported value for a libmagic parameter.
  fun magic_getmaxparam(param : LibC::Int) : LibC::SSizeT
end

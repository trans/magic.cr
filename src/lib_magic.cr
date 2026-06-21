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

  alias Handle = Void*

  fun magic_open(flags : LibC::Int) : Handle
  fun magic_close(cookie : Handle) : Void

  fun magic_getpath(magicfile : LibC::Char*, action : LibC::Int) : LibC::Char*
  fun magic_file(cookie : Handle, filename : LibC::Char*) : LibC::Char*
  fun magic_descriptor(cookie : Handle, fd : LibC::Int) : LibC::Char*
  fun magic_buffer(cookie : Handle, buffer : Void*, length : LibC::SizeT) : LibC::Char*

  fun magic_error(cookie : Handle) : LibC::Char*
  fun magic_getflags(cookie : Handle) : LibC::Int
  fun magic_setflags(cookie : Handle, flags : LibC::Int) : LibC::Int

  fun magic_version : LibC::Int
  fun magic_load(cookie : Handle, filename : LibC::Char*) : LibC::Int
  fun magic_load_buffers(cookie : Handle, buffers : Void**, sizes : LibC::SizeT*, nbuffers : LibC::SizeT) : LibC::Int

  fun magic_compile(cookie : Handle, filename : LibC::Char*) : LibC::Int
  fun magic_check(cookie : Handle, filename : LibC::Char*) : LibC::Int
  fun magic_list(cookie : Handle, filename : LibC::Char*) : LibC::Int
  fun magic_errno(cookie : Handle) : LibC::Int

  fun magic_setparam(cookie : Handle, param : LibC::Int, value : Void*) : LibC::Int
  fun magic_getparam(cookie : Handle, param : LibC::Int, value : Void*) : LibC::Int
  fun magic_getmaxparam(param : LibC::Int) : LibC::SSizeT
end

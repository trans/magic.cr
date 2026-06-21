require "./lib_magic"

module Magic
  VERSION = "0.1.1"

  @[Flags]
  enum Flag
    None           = LibMagic::MAGIC_NONE
    Debug          = LibMagic::MAGIC_DEBUG
    Symlink        = LibMagic::MAGIC_SYMLINK
    Compress       = LibMagic::MAGIC_COMPRESS
    Devices        = LibMagic::MAGIC_DEVICES
    MimeType       = LibMagic::MAGIC_MIME_TYPE
    Continue       = LibMagic::MAGIC_CONTINUE
    Check          = LibMagic::MAGIC_CHECK
    PreserveAtime  = LibMagic::MAGIC_PRESERVE_ATIME
    Raw            = LibMagic::MAGIC_RAW
    Error          = LibMagic::MAGIC_ERROR
    MimeEncoding   = LibMagic::MAGIC_MIME_ENCODING
    Mime           = LibMagic::MAGIC_MIME
    Apple          = LibMagic::MAGIC_APPLE
    Extension      = LibMagic::MAGIC_EXTENSION
    CompressTransp = LibMagic::MAGIC_COMPRESS_TRANSP
    NoCompressFork = LibMagic::MAGIC_NO_COMPRESS_FORK
    NoDesc         = LibMagic::MAGIC_NODESC

    NoCheckCompress = LibMagic::MAGIC_NO_CHECK_COMPRESS
    NoCheckTar      = LibMagic::MAGIC_NO_CHECK_TAR
    NoCheckSoft     = LibMagic::MAGIC_NO_CHECK_SOFT
    NoCheckApptype  = LibMagic::MAGIC_NO_CHECK_APPTYPE
    NoCheckElf      = LibMagic::MAGIC_NO_CHECK_ELF
    NoCheckText     = LibMagic::MAGIC_NO_CHECK_TEXT
    NoCheckCdf      = LibMagic::MAGIC_NO_CHECK_CDF
    NoCheckCsv      = LibMagic::MAGIC_NO_CHECK_CSV
    NoCheckTokens   = LibMagic::MAGIC_NO_CHECK_TOKENS
    NoCheckEncoding = LibMagic::MAGIC_NO_CHECK_ENCODING
    NoCheckJson     = LibMagic::MAGIC_NO_CHECK_JSON
    NoCheckSimh     = LibMagic::MAGIC_NO_CHECK_SIMH
    NoCheckBuiltin  = LibMagic::MAGIC_NO_CHECK_BUILTIN
  end

  class Error < Exception
    getter errno : Int32?

    def initialize(message : String, @errno : Int32? = nil)
      super(message)
    end
  end

  class Database
    def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true) : self
      new(flags, database, load)
    end

    def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true, &)
      database_handle = new(flags, database, load)
      begin
        yield database_handle
      ensure
        database_handle.close
      end
    end

    def initialize(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true)
      @handle = LibMagic.magic_open(flag_value(flags))
      raise Error.new("failed to allocate libmagic handle") if @handle.null?

      load(database) if load
    end

    def finalize
      close
    end

    def close : Nil
      return if closed?

      LibMagic.magic_close(@handle)
      @handle = Pointer(Void).null
    end

    def closed? : Bool
      @handle.null?
    end

    def load(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_load(handle, database_path)
      else
        check LibMagic.magic_load(handle, Pointer(LibC::Char).null)
      end

      self
    end

    def check(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_check(handle, database_path)
      else
        check LibMagic.magic_check(handle, Pointer(LibC::Char).null)
      end

      self
    end

    def compile(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_compile(handle, database_path)
      else
        check LibMagic.magic_compile(handle, Pointer(LibC::Char).null)
      end

      self
    end

    def list(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_list(handle, database_path)
      else
        check LibMagic.magic_list(handle, Pointer(LibC::Char).null)
      end

      self
    end

    def file(path : String | Path) : String
      file_path = path.to_s
      string_or_raise LibMagic.magic_file(handle, file_path)
    end

    def descriptor(fd : Int) : String
      string_or_raise LibMagic.magic_descriptor(handle, fd.to_i32)
    end

    def buffer(bytes : Bytes) : String
      string_or_raise LibMagic.magic_buffer(handle, bytes.to_unsafe.as(Void*), bytes.size)
    end

    def buffer(string : String) : String
      buffer string.to_slice
    end

    def flags : Int32
      LibMagic.magic_getflags(handle).to_i32
    end

    def flags=(flags : Flag | Int32) : Flag | Int32
      check LibMagic.magic_setflags(handle, flag_value(flags))
      flags
    end

    private def handle : LibMagic::Handle
      raise Error.new("libmagic handle is closed") if closed?

      @handle
    end

    private def flag_value(flags : Flag) : Int32
      flags.value
    end

    private def flag_value(flags : Int32) : Int32
      flags
    end

    private def check(result : Int) : Nil
      raise_last_error if result == -1
    end

    private def string_or_raise(pointer : LibC::Char*) : String
      raise_last_error if pointer.null?

      String.new(pointer)
    end

    private def raise_last_error
      pointer = LibMagic.magic_error(handle)
      message = pointer.null? ? "libmagic error" : String.new(pointer)
      errno = LibMagic.magic_errno(handle)

      raise Error.new(message, errno == 0 ? nil : errno.to_i32)
    end
  end

  def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true) : Database
    Database.open(flags, database, load)
  end

  def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true, &)
    Database.open(flags, database, load) do |database_handle|
      yield database_handle
    end
  end

  def self.file(path : String | Path, flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil) : String
    open(flags, database) do |database_handle|
      database_handle.file(path)
    end
  end

  def self.buffer(bytes : Bytes, flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil) : String
    open(flags, database) do |database_handle|
      database_handle.buffer(bytes)
    end
  end

  def self.buffer(string : String, flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil) : String
    buffer(string.to_slice, flags, database)
  end

  def self.version : Int32
    LibMagic.magic_version.to_i32
  end
end

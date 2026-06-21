require "./lib_magic"

# High-level Crystal wrapper for libmagic.
#
# Use this module for normal Crystal code. It opens libmagic handles, loads the
# magic database, converts C strings into Crystal strings, raises `Magic::Error`
# on failure, and closes handles automatically when using the block APIs.
#
# Use `LibMagic` directly when you need exact access to the underlying C API.
module Magic
  # Shard version.
  VERSION = "0.1.1"

  # Flags that control libmagic lookup behavior.
  #
  # The enum maps directly to the `MAGIC_*` constants from libmagic. Values can
  # be combined with `|`.
  #
  # ```
  # flags = Magic::Flag::MimeType | Magic::Flag::Error
  # puts Magic.file("README.md", flags)
  # ```
  @[Flags]
  enum Flag
    # No special lookup behavior.
    None = LibMagic::MAGIC_NONE
    # Print debugging information to stderr.
    Debug = LibMagic::MAGIC_DEBUG
    # Follow symlinks.
    Symlink = LibMagic::MAGIC_SYMLINK
    # Inspect compressed files by decompressing their contents.
    Compress = LibMagic::MAGIC_COMPRESS
    # Inspect block and character devices.
    Devices = LibMagic::MAGIC_DEVICES
    # Return a MIME type, such as `text/plain`.
    MimeType = LibMagic::MAGIC_MIME_TYPE
    # Return all matches instead of only the first match.
    Continue = LibMagic::MAGIC_CONTINUE
    # Check magic database consistency and print warnings to stderr.
    Check = LibMagic::MAGIC_CHECK
    # Try to preserve file access times where supported.
    PreserveAtime = LibMagic::MAGIC_PRESERVE_ATIME
    # Do not escape unprintable characters.
    Raw = LibMagic::MAGIC_RAW
    # Treat filesystem errors as lookup errors.
    Error = LibMagic::MAGIC_ERROR
    # Return the MIME encoding, such as `us-ascii`.
    MimeEncoding = LibMagic::MAGIC_MIME_ENCODING
    # Return MIME type and MIME encoding.
    Mime = LibMagic::MAGIC_MIME
    # Return Apple creator and type information.
    Apple = LibMagic::MAGIC_APPLE
    # Return slash-separated file extensions.
    Extension = LibMagic::MAGIC_EXTENSION
    # Inspect compressed files without reporting the compression wrapper.
    CompressTransp = LibMagic::MAGIC_COMPRESS_TRANSP
    # Disable decompressors that require forking.
    NoCompressFork = LibMagic::MAGIC_NO_COMPRESS_FORK
    # Suppress descriptive output classes.
    NoDesc = LibMagic::MAGIC_NODESC

    # Do not inspect compressed data.
    NoCheckCompress = LibMagic::MAGIC_NO_CHECK_COMPRESS
    # Do not inspect tar files.
    NoCheckTar = LibMagic::MAGIC_NO_CHECK_TAR
    # Do not consult magic database entries.
    NoCheckSoft = LibMagic::MAGIC_NO_CHECK_SOFT
    # Do not check application type.
    NoCheckApptype = LibMagic::MAGIC_NO_CHECK_APPTYPE
    # Do not inspect ELF details.
    NoCheckElf = LibMagic::MAGIC_NO_CHECK_ELF
    # Do not run text-file checks.
    NoCheckText = LibMagic::MAGIC_NO_CHECK_TEXT
    # Do not inspect CDF / Microsoft compound document data.
    NoCheckCdf = LibMagic::MAGIC_NO_CHECK_CDF
    # Do not inspect CSV data.
    NoCheckCsv = LibMagic::MAGIC_NO_CHECK_CSV
    # Do not inspect known tokens in text data.
    NoCheckTokens = LibMagic::MAGIC_NO_CHECK_TOKENS
    # Do not inspect text encodings.
    NoCheckEncoding = LibMagic::MAGIC_NO_CHECK_ENCODING
    # Do not inspect JSON data.
    NoCheckJson = LibMagic::MAGIC_NO_CHECK_JSON
    # Do not inspect SIMH tape data.
    NoCheckSimh = LibMagic::MAGIC_NO_CHECK_SIMH
    # Disable built-in checks while still allowing database checks.
    NoCheckBuiltin = LibMagic::MAGIC_NO_CHECK_BUILTIN
  end

  # Exception raised for libmagic failures.
  #
  # When libmagic reports an operating system error, `#errno` contains that
  # errno value. Otherwise it is `nil`.
  class Error < Exception
    # Operating system errno reported by libmagic, when available.
    getter errno : Int32?

    def initialize(message : String, @errno : Int32? = nil)
      super(message)
    end
  end

  # Reusable libmagic database handle.
  #
  # A database owns a `LibMagic::Handle`. Use `Magic.open` or
  # `Magic::Database.open` with a block when possible so the handle is closed
  # deterministically.
  class Database
    # Opens a reusable database handle.
    #
    # If *load* is `true`, the default magic database or the given *database*
    # path is loaded immediately.
    def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true) : self
      new(flags, database, load)
    end

    # Opens a database handle, yields it, and closes it after the block exits.
    def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true, &)
      database_handle = new(flags, database, load)
      begin
        yield database_handle
      ensure
        database_handle.close
      end
    end

    # Creates a database handle.
    #
    # Pass *load* as `false` when you need to call `#load`, `#check`,
    # `#compile`, or `#list` manually before running lookups.
    def initialize(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true)
      @handle = LibMagic.magic_open(flag_value(flags))
      raise Error.new("failed to allocate libmagic handle") if @handle.null?

      load(database) if load
    end

    # Closes the handle during garbage collection if it was not closed already.
    def finalize
      close
    end

    # Closes the underlying libmagic handle.
    #
    # Calling this more than once is safe.
    def close : Nil
      return if closed?

      LibMagic.magic_close(@handle)
      @handle = Pointer(Void).null
    end

    # Returns `true` if the underlying libmagic handle has been closed.
    def closed? : Bool
      @handle.null?
    end

    # Loads the default magic database or the database at *database*.
    def load(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_load(handle, database_path)
      else
        check LibMagic.magic_load(handle, Pointer(LibC::Char).null)
      end

      self
    end

    # Checks the default magic database or the database at *database*.
    def check(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_check(handle, database_path)
      else
        check LibMagic.magic_check(handle, Pointer(LibC::Char).null)
      end

      self
    end

    # Compiles the default magic database or the database at *database*.
    def compile(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_compile(handle, database_path)
      else
        check LibMagic.magic_compile(handle, Pointer(LibC::Char).null)
      end

      self
    end

    # Prints a human-readable listing of the default magic database or the
    # database at *database*.
    def list(database : String | Path | Nil = nil) : self
      if database
        database_path = database.to_s
        check LibMagic.magic_list(handle, database_path)
      else
        check LibMagic.magic_list(handle, Pointer(LibC::Char).null)
      end

      self
    end

    # Identifies a file by path and returns the libmagic result string.
    def file(path : String | Path) : String
      file_path = path.to_s
      string_or_raise LibMagic.magic_file(handle, file_path)
    end

    # Identifies the data available from an open file descriptor.
    def descriptor(fd : Int) : String
      string_or_raise LibMagic.magic_descriptor(handle, fd.to_i32)
    end

    # Identifies a byte slice and returns the libmagic result string.
    def buffer(bytes : Bytes) : String
      string_or_raise LibMagic.magic_buffer(handle, bytes.to_unsafe.as(Void*), bytes.size)
    end

    # Identifies a string's bytes and returns the libmagic result string.
    def buffer(string : String) : String
      buffer string.to_slice
    end

    # Returns the current libmagic flags as an integer bitmask.
    def flags : Int32
      LibMagic.magic_getflags(handle).to_i32
    end

    # Replaces the current libmagic flags.
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

  # Opens a reusable database handle.
  def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true) : Database
    Database.open(flags, database, load)
  end

  # Opens a reusable database handle, yields it, and closes it after the block.
  def self.open(flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil, load : Bool = true, &)
    Database.open(flags, database, load) do |database_handle|
      yield database_handle
    end
  end

  # One-shot file identification helper.
  #
  # Opens a database handle, loads the database, identifies *path*, closes the
  # handle, and returns the libmagic result string.
  def self.file(path : String | Path, flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil) : String
    open(flags, database) do |database_handle|
      database_handle.file(path)
    end
  end

  # One-shot byte-slice identification helper.
  #
  # Opens a database handle, loads the database, identifies *bytes*, closes the
  # handle, and returns the libmagic result string.
  def self.buffer(bytes : Bytes, flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil) : String
    open(flags, database) do |database_handle|
      database_handle.buffer(bytes)
    end
  end

  # One-shot string identification helper.
  def self.buffer(string : String, flags : Flag | Int32 = Flag::None, database : String | Path | Nil = nil) : String
    buffer(string.to_slice, flags, database)
  end

  # Returns the linked libmagic version number.
  def self.version : Int32
    LibMagic.magic_version.to_i32
  end
end

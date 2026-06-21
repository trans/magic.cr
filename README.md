# magic.cr

Crystal bindings for `libmagic`, the library used by the Unix `file` command
to identify file types from their contents.

The shard provides a small Crystal-friendly wrapper for common use and exposes
the raw C API through `LibMagic` when you need direct access.

## Requirements

- Crystal `>= 1.16.0`
- `libmagic`
- The libmagic development headers

Install libmagic before building applications that depend on this shard:

```sh
# Debian/Ubuntu
sudo apt install libmagic-dev

# Fedora
sudo dnf install file-devel

# Arch
sudo pacman -S file

# macOS
brew install libmagic
```

## Installation

Add the shard to your `shard.yml`:

```yaml
dependencies:
  magic:
    github: trans/magic.cr
    version: ~> 0.1.1
```

Then install dependencies:

```sh
shards install
```

## Usage

```crystal
require "magic"

puts Magic.file("README.md")
# => ASCII text

puts Magic.file("README.md", Magic::Flag::MimeType)
# => text/plain

puts Magic.buffer("hello\n")
# => ASCII text
```

For repeated lookups, keep a database handle open:

```crystal
Magic.open do |magic|
  puts magic.file("README.md")
  puts magic.buffer("hello\n")
end
```

You can pass libmagic flags when opening a handle:

```crystal
Magic.open(Magic::Flag::MimeType | Magic::Flag::Symlink) do |magic|
  puts magic.file("README.md")
end
```

Or use a one-shot helper:

```crystal
mime_type = Magic.file("README.md", Magic::Flag::MimeType)
```

## API

### One-shot helpers

```crystal
Magic.file(path, flags = Magic::Flag::None, database = nil)
Magic.buffer(bytes, flags = Magic::Flag::None, database = nil)
Magic.buffer(string, flags = Magic::Flag::None, database = nil)
Magic.version
```

These helpers open libmagic, load the database, run one lookup, and close the
handle.

### Reusable database handle

```crystal
magic = Magic::Database.open(Magic::Flag::MimeType)
magic.file("README.md")
magic.buffer("hello\n")
magic.descriptor(fd)
magic.close
```

Prefer the block form so the handle is always closed:

```crystal
Magic::Database.open(Magic::Flag::MimeType) do |magic|
  puts magic.file("README.md")
end
```

A custom magic database path can be passed as the second argument:

```crystal
Magic.open(Magic::Flag::None, "/path/to/magic.mgc") do |magic|
  puts magic.file("sample.bin")
end
```

### Flags

`Magic::Flag` maps the libmagic flags into a Crystal flags enum. Common values
include:

- `Magic::Flag::MimeType`
- `Magic::Flag::MimeEncoding`
- `Magic::Flag::Mime`
- `Magic::Flag::Symlink`
- `Magic::Flag::Compress`
- `Magic::Flag::Error`
- `Magic::Flag::Extension`

Flags can be combined with `|`:

```crystal
flags = Magic::Flag::MimeType | Magic::Flag::Error
puts Magic.file("README.md", flags)
```

## Errors

libmagic failures raise `Magic::Error`:

```crystal
begin
  Magic.file("missing.file", Magic::Flag::Error)
rescue error : Magic::Error
  puts error.message
  puts error.errno
end
```

## Raw LibMagic API

The low-level binding is available as `LibMagic`:

```crystal
handle = LibMagic.magic_open(LibMagic::MAGIC_MIME_TYPE)
LibMagic.magic_load(handle, Pointer(LibC::Char).null)
puts String.new(LibMagic.magic_file(handle, "README.md"))
LibMagic.magic_close(handle)
```

Use this layer when you need a libmagic function that the wrapper does not
abstract.

## Development

Run the specs:

```sh
CRYSTAL_CACHE_DIR=/tmp/crystal-cache crystal spec
```

Format source and specs:

```sh
crystal tool format src spec
```

## License

MIT. See [LICENSE](LICENSE).

## Contributors

- [Thomas Sawyer](https://github.com/trans) - creator and maintainer

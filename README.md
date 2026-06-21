# magic

Crystal bindings for [`libmagic`](https://darwinsys.com/file/), the library
behind the `file` command.

## Installation

Install the libmagic development package for your system first:

```sh
# Debian/Ubuntu
sudo apt install libmagic-dev

# Fedora
sudo dnf install file-devel

# macOS
brew install libmagic
```

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     magic:
       github: transfire/magic.cr
   ```

2. Run `shards install`

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
Magic.open(Magic::Flag::MimeType) do |magic|
  puts magic.file("README.md")
  puts magic.buffer("hello\n")
end
```

Use `LibMagic` directly for the raw C API:

```crystal
handle = LibMagic.magic_open(LibMagic::MAGIC_MIME_TYPE)
LibMagic.magic_load(handle, Pointer(LibC::Char).null)
puts String.new(LibMagic.magic_file(handle, "README.md"))
LibMagic.magic_close(handle)
```

## Development

Run specs with a writable Crystal cache:

```sh
CRYSTAL_CACHE_DIR=/tmp/crystal-cache crystal spec
```

## Contributing

1. Fork it (<https://github.com/transfire/magic.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Thomas Sawyer](https://github.com/transfire) - creator and maintainer

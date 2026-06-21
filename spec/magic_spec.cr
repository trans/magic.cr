require "./spec_helper"

describe Magic do
  it "reports the linked libmagic version" do
    Magic.version.should be > 0
  end

  it "detects a buffer" do
    Magic.buffer("hello\n").should contain("text")
  end

  it "detects a MIME type" do
    Magic.buffer("hello\n", Magic::Flag::MimeType).should eq("text/plain")
  end

  it "detects a file" do
    file = File.tempfile("magic", ".txt")
    path = file.path
    file.print "hello\n"
    file.close

    begin
      Magic.file(path, Magic::Flag::MimeType).should eq("text/plain")
    ensure
      File.delete(path) if File.exists?(path)
    end
  end

  it "closes block-scoped handles" do
    database = nil

    Magic.open do |magic|
      database = magic
      magic.closed?.should be_false
    end

    database.not_nil!.closed?.should be_true
  end

  it "raises libmagic errors" do
    expect_raises(Magic::Error) do
      Magic.file("/definitely/not/a/file", Magic::Flag::Error)
    end
  end
end

# This spec is designed to test the program "all-up" given a set of fixture files.

require "spec_helper"

# using open3 lets us capture stdout, stderr and exit status.
require "open3"

describe "parser.rb" do
  subject(:command) { "./parser.rb #{fixture_path}" }

  context "with no arguments" do
    let(:fixture_path) { "" }
    it "returns an error" do
      stdout, stderr, status = Open3.capture3(command)
      expect(status.success?).to eq(false)
      expect(stdout).to eq("") # no output on stdout for an error
      expect(stderr).to match(/please provide a file to analyse/)
      expect(stderr).to match(/e.g. .\/parser.rb filename.log/)
    end
  end

  context "with a basic file" do
    # The basic fixture contains three log lines; two for one path and one for another.
    # It was created by snipping a couple of lines from the provided example file.
    let(:fixture_path) { "spec/fixtures/basic.log" }

    it "returns a summary" do
      stdout, stderr, status = Open3.capture3(command)
    end
  end
end

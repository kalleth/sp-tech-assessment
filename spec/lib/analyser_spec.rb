require "spec_helper"
require "analyser"

# The analyser is the "glue". It takes a file IO stream which can be iterated
# over, hands it off to a "Scanner", which yields a path and IP address, and
# sends that information to a Repository, which stores each line (in memory)
# ready for later querying.
#
# This test has lots of mocks and stubs; I toyed with the idea of not writing
# this spec and letting the integration spec handle this. But that probably
# wouldn't be good form...
describe Analyser do
  let(:handle) { double(:file) }
  let(:output_stream) { double(:stdout, puts: nil) }

  # could also use mock classes here; class MockScanner < Struct.new(:handle); end
  let(:scanner_klass) { double(:scanner_klass, new: mock_scanner) }
  let(:mock_scanner) { double(:scanner, each_entry: "") }
  let(:repo_klass) { double(:repo_klass, new: mock_repo) }
  let(:mock_repo) { double(:repo, each_by_hits: []) }

  subject(:analyser) {
    Analyser.new(
      handle: handle,
      output_stream: output_stream,
      scanner_klass: scanner_klass,
      repo_klass: repo_klass,
    )
  }

  it "stores each line from the handle" do
    allow(mock_scanner).to receive(:each_entry).
      and_yield("/path", "1.1.1.1").
      and_yield("/path", "1.1.1.1")

    expect(mock_repo).to receive(:store).twice

    subject.call
  end

  it "outputs the results to the output stream" do
    allow(mock_repo).to receive(:each_by_hits).and_return([
      { path: "/path", hits: 3 },
    ])

    expect(output_stream).to receive(:puts).with("/path 3 visits")

    subject.call
  end
end

require "spec_helper"
require "scanner"

describe Scanner do
  subject(:scanner) { described_class.new(string_io) }
  let(:string_io) { StringIO.new(test_string) }

  context "with a basic fixture" do
    # Ruby 2.3 introduced squiggly heredocs that strip whitespace. <3 Ruby
    let(:test_string) {
      <<~HEREDOC
      /home 184.123.665.067
      /home 444.701.448.104
      /index 444.701.448.104
      HEREDOC
    }

    it "yields each line" do
      expect { |b| scanner.each_entry(&b) }.to yield_control.exactly(3).times
    end

    it "yields the path and IP correctly" do
      expect { |b| scanner.each_entry(&b) }.to yield_successive_args(
        ["/home", "184.123.665.067"],
        ["/home", "444.701.448.104"],
        ["/index", "444.701.448.104"],
      )
    end
  end
end

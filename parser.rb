#!/usr/bin/env ruby

require_relative "lib/analyser"

# Let's start off using the ruby ARGV array. It's not the most robust (optparse
# or similar might work better) but for just providing a path to a file it's
# adequate.

if ARGV.size < 1
  STDERR.puts "please provide a file to analyse!"
  STDERR.puts "e.g. ./parser.rb filename.log"
  # break out with an unsuccessful execution
  exit 1
end

# At this stage, we can assume ARGV[0] contains a path to a file. Let's create
# a file object pointing to it and bomb out if we can't access that file.

file_path = ARGV[0]

begin
  file_handle = File.open(file_path, "r") # "r" is the default file open mode
rescue Errno::ENOENT
  # This error is raised mostly if the file doesn't exist
  STDERR.puts "file #{file_path} does not exist!"
  exit 1
end

# Now we've got a file handle pointing to a valid file. Let's start some analysis...
analyser = Analyser.new(
  handle: file_handle,
  output_stream: STDOUT,
)

analyser.call

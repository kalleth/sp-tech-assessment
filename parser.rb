#!/usr/bin/env ruby

# Let's start off using the ruby ARGV array. It's not the most robust (optparse
# or similar might work better) but for just providing a path to a file it's
# adequate.

if ARGV.size < 1
  STDERR.puts "please provide a file to analyse!"
  STDERR.puts "e.g. ./parser.rb filename.log"
  # break out with an unsuccessful execution
  exit 1
end

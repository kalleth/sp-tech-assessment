require_relative "scanner"
require_relative "in_memory_repository"

class Analyser
  def initialize(handle:, output_stream:, scanner_klass: Scanner, repo_klass: InMemoryRepository)
    @handle = handle
    @output_stream = output_stream
    @scanner_klass = scanner_klass
    @repo_klass = repo_klass
  end

  def call
    scanner.each_entry do |path, ip|
      repo.store(path, ip)
    end

    output_stream.puts "Page paths ordered by hits:"
    repo.each_by_hits.each do |record|
      output_stream.puts "#{record[:path]} #{record[:hits]} visits"
    end

    output_stream.puts "\r\nPage paths ordered by uniques:"
    repo.each_by_uniques.each do |record|
      output_stream.puts "#{record[:path]} #{record[:uniques]} uniques"
    end
  end

  private
  attr_reader :handle, :output_stream, :scanner_klass, :repo_klass

  def scanner
    @scanner ||= scanner_klass.new(handle)
  end

  def repo
    @repo ||= repo_klass.new
  end
end

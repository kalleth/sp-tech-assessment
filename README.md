# Log line parser - SmartPension Tech Assessment

## Architecture

The basic plan here is to create a "glue" class, called from the command-line
script, which accepts a "file IO" stream (i.e. the log file to analyse), and
uses a Scanner and a Repository (for now) to perform analysis on that file.

The scanner is responsible for parsing the file, and yielding the hostname and
IP to the caller, line by line.

The repository accepts those lines, and stores them into memory, to -- for now
-- be queried later using inefficient sorting and counting queries.

Eventually, the repository can be made more intelligent, parsing each line as
it comes in and using that to build a data structure (or two) that can be
queried fast later on to display the data -- this is similar to how a database
would "index" data, and update those indexes as new data comes in.

Ideally, this will look something like the following (pseudocode):

```ruby
scanner = Scanner.new(file_handle)
repository = Repository.new

scanner.each_entry do |path, ip|
  repository.store(path, ip)
end

repository.each_by_hits do |path, hit_total|
  STDOUT.puts "#{path} #{hit_total} visits"
end
```

Using dependency injection to send in the Scanner and Repository objects allows
flex; a different log file format can be handled with a different Scanner, and
a different storage mechanism (like, for example, Elasticsearch or MySQL or..)
could be swapped out by switching the repository.

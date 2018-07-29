# Log line parser - SP Tech Assessment

First clone the repo, or extract the git repo from the zip file I've provided.

Then, using ruby 2.4 (see .ruby-version), `bundle install`.

Finally, the tests can be run with `rspec` or the full script run with
`./parser.rb fixtures/webserver.log`

## Architecture

The basic plan here was to create a "glue" class, called from the command-line
script, which accepts a "file IO" stream (i.e. the log file to analyse), and
uses a Scanner and a Repository to perform analysis on that file.

The scanner is responsible for parsing the file, and yielding the hostname and
IP to the caller, line by line.

The repository accepts those lines, and stores them into memory, to be queried
later using inefficient sorting and counting queries.

Eventually, the repository could be made more intelligent, parsing each line as
it comes in and using that to build a data structure (or two) that can be
queried fast later on to display the data -- this is similar to how a database
would "index" data, and update those indexes as new data comes in. See below
for a discussion of this.

Using dependency injection to send in the Scanner and Repository objects allows
flex; a different log file format can be handled with a different Scanner, and
a different storage mechanism (like, for example, Elasticsearch or MySQL or..)
could be swapped out by switching the repository.

## Review vs brief

### Functionality

Lists paths by both page views and uniques. Correct values are obtained.

I've verified this with bash commands. Script output on the test file:

```
$./parser.rb fixtures/webserver.log
Page paths ordered by hits:
/about/2 90 visits
/contact 89 visits
/index 82 visits
/about 81 visits
/help_page/1 80 visits
/home 78 visits

Page paths ordered by uniques:
/help_page/1 23 uniques
/contact 23 uniques
/home 23 uniques
/index 23 uniques
/about/2 22 uniques
/about 21 uniques
```

Picking "/about/2" as an example, we can verify this with the following commands:

```
$ cat fixtures/webserver.log | grep /about/2 | sort | wc -l
90

$ cat fixtures/webserver.log | grep /about/2 | sort | uniq | wc -l
22
```

These figures match with the output of the parser.

### Efficiency

#### Of code

I'm biased, but I like the architecture here. The separation of
responsibilities is clean and clear in most cases.

* `parser.rb` - command-line usage only; argument validation, obtaining a file handle.
* `lib/analyser.rb` - acts somewhat like a "controller", connecting a Scanner,
  Repository and the various input and output streams.
* `lib/scanner.rb` - parses the input file, yielding specific objects (path, ip) back to the analyser.
* `lib/in_memory_repository.rb` - handles storing and sorting the incoming objects.

It's _possible_ that specifically calling out the InMemoryRepository is a step
too far, but it's a nice easy step for future enhancement to replace it with a
database backed key which could improve sorting and querying efficiency for
large files.

It's also possible that the `Analyser` does a bit too much, and should hand off
to another class to render output to the screen (an `OutputRenderer` or
similar).

#### Of speed

This hasn't been my focus for this exercise; the implemented system is probably
O(3n) as it needs to iterate through the provided set three times to produce
output; once to store, and twice to sort.

It's possible (as described above) that an "index" of sorts, that's presorted,
could be produced by modifying `InMemoryRepository#store` to build up a
different data structure, reducing algorithmic complexity.

Given the provided file is only 500 lines long, that seems unnecessary at this
stage.

If efficiency is a critical concern, log analysis can be handled better at
scale with an ELK (Elasticsearch-Logstash-Kibana) stack, or some other form of
log analysis tool.

Alternatively, the use of bash commands above to generate these figures implies
that a command-line solution using a combination of `sed` / `awk` / `sort` /
`uniq` should be possible with little effort, and is likely to be much more
performant.

### Readability

To ensure clear legibility, I've kept my method names short but descriptive,
and there is a comprehensive test suite with test names and contexts written
mostly in accordance with `betterspecs.org`

### Tests

A full test suite exists in `/spec`, accessible by running `rspec` from the
command line.

Installing simplecov (see previous commit) shows code coverage is at 100%. I
have committed my latest coverage report to this repository.

## Next steps

### Potential improvements

* `parser.rb` - switch to `optparse` to parse command-line flags and allow
  switching between uniques, hits, or both.
* `parser.rb` - more validation around file access (we don't test we can read
  it before entering the analyser, f.e.)
* `parser.rb` - add `--help` commandline flag describing usage
* `lib/analyser.rb` - extract a class responsible for outputting to the command
  line in the correct format.
* `lib/in_memory_repository.rb` - Improve the efficiency of sorting by
  pregenerating sorted arrays in #store
* `lib/sql_repository.rb` - Use a MySQL repository to insert and query data;
  this might make the sorting quicker as you can let the database engine handle
  sorting the data as required for larger datasets.
* `lib/scanner.rb` - use of `String#split` here might be brittle with truncated
  or corrupted datasets.

### Other ways to solve the issue at scale

* Use bash commands (`awk`, `sed`, `uniq`, `sort`) to solve the problem with
  unix pipes.
* Install an ELK stack and have the webserver log directly to that, then query
  it directly using Kibana's query syntax.
* Use a third-party tool such as logmatic.io, papertrail, loggly or graylog.

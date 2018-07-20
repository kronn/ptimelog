# gPuzzleTime

small tooling to transfer timelog-entries from gtimelog's timelog.txt to the PuzzleTime TimeTracking Website.

## Approach

- [x] read timelog.txt
  - [x] from known location
  - [ ] later: configure location?
  - [ ] later: auto-detect location?
- [x] parse out last day
  - [x] especially start/end-times for each entry
  - [x] date - ticket - description
  - [x] later: parse out specific day
- [x] open N browser instances with the time entry data
  - [x] without selected account
- [x] infer time-account from ticket-format
  - [x] support user-supplied ticket-parsers
  - [x] get ticket-parser from tags
- [ ] merge equal adjacent entries into one
- [ ] complete login/entry automation
  - [ ] login
  - [ ] store cookie
  - [ ] make entries
  - [ ] open day in browser for review
- [ ] avoid duplicate entries
  - [ ] start/end time as indicator?
- [ ] offer rounding times to the next 5, 10 or 15 minutes
- [ ] allow to add entries from the command-line
- [ ] handle time-account and billable better
  - [ ] import time-accounts from ptime (https://time.puzzle.ch/work_items/search.json?q=search%20terms)
    - [ ] with a dedicated cli?
    - [ ] from a REST-Endpoint of PTime?
  - [ ] automatically prefill billable
    - [ ] from time-accounts
    - [ ] from *-notation
  - [ ] allow to have a list of "favourite" time-accounts
  - [ ] select best-matching time-account according to tags, possibly limited to the favourites


## Installation

Install it with:

    $ gem install gpuzzletime

## Usage

    $ gpuzzletime ACTION DATE

### Actions

Currently supported actions are

- show
- upload
- edit

### Date-Identifier

To handle a specific date, the format YYYY-MM-DD is expected, e.g. 2017-12-25. Please note that you should not work on that day, unless you bring presents.

For reusability in a shell-history the following keywords are supported:

- today
- yesterday
- last

If nothing is specified, the action is applied to all entries.

### Edit-Identifier

When the action is "edit", the next argument is treated as script that shoudl be edited.

If nothing is passed, the main timelog.txt is loaded.

Otherwise, a script to determine the time-account is loaded.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec gpuzzletime` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kronn/gpuzzletime.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

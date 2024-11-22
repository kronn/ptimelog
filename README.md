# pTimeLog

small tooling to transfer timelog-entries from gtimelog's timelog.txt or obsidian-notes to the PuzzleTime time-tracking web-application.

## Approach

- [x] read timelog.txt
  - [x] from known location
  - [x] later: configure location?
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
- [x] merge equal adjacent entries into one
- [ ] complete login/entry automation
  - [ ] handle authentication
    - [ ] login and store cookie (https://stackoverflow.com/questions/12399087/curl-to-access-a-page-that-requires-a-login-from-a-different-page#12399176)
    - [ ] send user and pwd with every request
  - [ ] make entries
  - [ ] open day in browser for review
- [x] avoid duplicate entries
  - [x] start/end time as indicator?
- [x] offer rounding times to the next 5, 10 or 15 minutes
- [x] allow to add entries from the command-line
- [ ] handle time-account and billable better
  - [ ] import time-accounts from ptime (https://time.puzzle.ch/work_items/search.json?q=search%20terms)
    - [ ] with a dedicated cli?
    - [ ] from a REST-Endpoint of PTime?
  - [ ] automatically prefill billable
    - [x] from time-accounts
    - [ ] from *-notation
  - [ ] allow to have a list of "favourite" time-accounts
  - [ ] select best-matching time-account according to tags, possibly limited to the favourites
  - [x] combine billable and account-lookup into one script
- [ ] add cli-help
  - [ ] use commander for CLI?

## Installation

Install it with:

    $ gem install ptimelog

## Usage

    $ ptimelog ACTION DATE

### Actions

Currently supported actions are

- show
- upload
- edit
- add
- version

### Date-Identifier

To handle a specific date, the format YYYY-MM-DD is expected, e.g. 2017-12-25.
Please note that you should not work on that day, unless you bring presents.

For reusability in a shell-history the following keywords are supported:

- today
- yesterday
- last
- all

If nothing is specified, the action is applied to entries of the last day.

### Edit-Identifier

When the action is "edit", the next argument is treated as script that should
be edited.

If nothing is passed, the main timelog.txt is loaded.

Otherwise, a script to determine the time-account is loaded.

### Adding entries

In order to add entries with the ptimelog-cli, the complete entry needs to be
quoted on the command-line to count as one argument.

    $ ptimelog add 'ticket 1337: Implement requirements -- client coding'

While this requires some knowledge of the file-format, it is no different than
entering the same string in gTimelog. For now, the entry is added to the
timelog.txt as it is passed. By default, the date/time added to the entry is
the one when the command is executed.

You can prefix a positive or negative signed number to slightly skew the entry
(think: '-5 meeting' or '+5 lunch \*\*') or even set a precise time ('10:30
meeting').

    $ ptimelog add '-5 meeting: Discuss requirements -- client planning'

### Showing the Version

I got tired of asking rubygems which version I installed, so I took on the
herculean task of letting ptimelog show its own version.

### Formatting the Output

In order to format the output of the show-action into a table, a hopefully
convienient field-marker has been chosen. I think it is unlikely, that ∴ is
being used in a time-entry. Therefore, you can pipe the output into `column`:

    ptimelog show today | column -t -s ∴

## Helper-Scripts

ptimelog can prefill the account-number and billable-state of an entry.

The tags are used to determine a script that helps infer the time-account.
These scripts should be located in `~/.config/ptimelog/inferers/` and be named
like the first tag used. The script gets the ticket, the description and all
remaining tags passed as arguments.

The output of the script should be the ID of the time-account and the
billable-state as "true" or "false". Both items need to be separated by
whitespace, so you can output those two on the same line or on different lines.

Since these scripts are called a lot, it is better to write them in a compiled
language. If you only like ruby, take a look at crystal. For such simple
scripts, the code is almost identical and "just" needs to be compiled.

## Configuration

A config-file is read from `$HOME/.config/ptimelog/config`. It is expected
to be a YAML-file. Currently, it supports the following keys:

  - rounding: [integer or false, default 15]
  - base_url: [url to your puzzletime-installation, default https://time.puzzle.ch]

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment. Run `bundle exec ptimelog` to use
the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kronn/ptimelog.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

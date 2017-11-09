# gPuzzleTime

small tooling to transfer timelog-entries from gtimelog's timelog.txt to the PuzzleTime TimeTracking Website.

## Approach

- [X] read timelog.txt
  - [X] from known location
  - [ ] later: configure location?
  - [ ] later: auto-detect location?
- [ ] parse out last day
  - [ ] especially start/end-times for each entry
  - [ ] date - ticket - description
  - [ ] later: parse out specific day
- [ ] open N browser instances with the time entry data
  - [ ] without selected account
- [ ] infer time-account from ticket-format
- [ ] ticket->account mappings from configuration
- [ ] complete login/entry automation
  - [ ] login
  - [ ] store cookie
  - [ ] make entries
  - [ ] open day in browser for review
- [ ] avoid duplicate entries
  - [ ] start/end time as indicator?
- [ ] offer rounding times to the next 5, 10 or 15 minutes


## Installation

Install it with:

    $ gem install gpuzzletime

## Usage

    $ gpuzzletime

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Run `bundle exec gpuzzletime` to use the gem in this directory, ignoring other installed copies of this gem.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kronn/gpuzzletime.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

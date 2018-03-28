# frozen_string_literal: true

require 'spec_helper'

describe Gpuzzletime::App do
  subject { described_class.new([command, argument].compact) }

  let(:command) { 'show' }
  let(:argument) { nil }
  let(:timelog) do
    <<-TIMELOG
2018-03-02 09:51: start
2018-03-02 11:40: 12345: prepare deployment -- webapp
2018-03-02 12:25: lunch **
2018-03-02 13:15: 12345: prepare deployment -- webapp
2018-03-02 14:30: break **
2018-03-02 16:00: handover
2018-03-02 17:18: cleanup database
2018-03-02 18:58: break **
2018-03-02 20:08: 12345: prepare deployment -- webapp

2018-03-03 14:00: start
2018-03-03 15:34: 23456: debug -- network
2018-03-03 18:46: studying
2018-03-03 20:08: dinner **
2018-03-03 21:36: 12345: prepare deployment -- webapp
    TIMELOG
  end

  # xit 'has a configurable puzzletime-domain'

  it 'can parse log-entries' do
    expect(subject.send(:parse, timelog)).to be_an Array
  end

  it 'parses into date/entries-pairs' do
    parsed_array = subject.send(:parse, timelog)

    expect(parsed_array).to be_an Array
    expect(parsed_array[0].count).to be 2
    expect(parsed_array[0][0]).to match(/\d{4}-\d{2}-\d{2}/)
    expect(parsed_array[0][1]).to be_an Array
    expect(parsed_array[0][1]).to all be_a(MatchData)
  end

  it 'omits entries ending in two stars' do
    expect(subject).to receive(:read).at_least(:once).and_return(timelog)

    expect { subject.run }.to output(/studying/).to_stdout
    expect { subject.run }.not_to output(/dinner/).to_stdout
    expect { subject.run }.not_to output(/lunch/).to_stdout
    expect { subject.run }.not_to output(/break/).to_stdout
  end

  # it 'knows some dates by relative names'

  # it 'can show parsed entries'
  # it 'can upload parsed entries'
  # it 'omits empty dates'
  # it 'can limit entries to one day'

  # it 'can load custom mappers for the ordertime_account'

  # it 'can open the timelog in an editor'
  # it 'can open a parser-script in an editor'
end

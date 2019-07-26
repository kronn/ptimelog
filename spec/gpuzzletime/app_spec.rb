# frozen_string_literal: true

require 'spec_helper'

describe Gpuzzletime::App do
  subject { described_class.new([command, argument].compact) }

  let(:command) { 'show' }
  let(:argument) { 'all' }
  let(:timelog) do
    Gpuzzletime::Timelog.instance.parse <<~TIMELOG
      2018-03-02 09:51: start **
      2018-03-02 11:40: 12345: prepare deployment -- webapp
      2018-03-02 12:25: lunch **
      2018-03-02 13:15: 12345: prepare deployment -- webapp
      2018-03-02 14:30: break **
      2018-03-02 16:00: handover
      2018-03-02 17:18: cleanup database
      2018-03-02 18:58: break **
      2018-03-02 20:08: 12345: prepare deployment -- webapp

      2018-03-03 14:00: start **
      2018-03-03 15:34: 23456: debug -- network
      2018-03-03 18:46: studying
      2018-03-03 20:08: dinner **
      2018-03-03 21:36: 12345: prepare deployment -- webapp

      2018-03-05 09:00: start **
    TIMELOG
  end
  let(:config) { {} }

  before :each do
    Gpuzzletime::Configuration.instance.reset

    config.each do |key, value|
      Gpuzzletime::Configuration.instance[key] = value
    end
  end

  it 'omits entries ending in two stars' do
    expect(subject).to receive(:timelog).at_least(:once).and_return(timelog)

    expect { subject.run }.to output(/studying/).to_stdout
    expect { subject.run }.not_to output(/dinner/).to_stdout
    expect { subject.run }.not_to output(/lunch/).to_stdout
    expect { subject.run }.not_to output(/break/).to_stdout
  end

  # it 'can show parsed entries'
  # it 'can upload parsed entries'
  # it 'omits empty dates'
  # it 'can limit entries to one day'

  # it 'can load custom mappers for the ordertime_account'

  # it 'can open the timelog in an editor'
  # it 'can open a parser-script in an editor'

  context 'just looking at one day, it' do
    let(:command) { :show }
    let(:argument) { '2018-03-02' }

    it 'rounds entry times to nearest 15 minutes' do
      expect(subject).to receive(:timelog).at_least(:once).and_return(timelog)

      expect { subject.run }.to output(/09:45 - 11:45/).to_stdout # rounding 9:41, 11:40 outwards
      expect { subject.run }.to output(/12:30 - 13:15/).to_stdout # rounding 12:25 up
      expect { subject.run }.to output(/14:30 - 16:00/).to_stdout # leaving round values as is
      expect { subject.run }.to output(/16:00 - 17:15/).to_stdout # rounding 17:18 down
      expect { subject.run }.to output(/19:00 - 20:15/).to_stdout # case of 18:60 -> 19:00
    end
  end
end

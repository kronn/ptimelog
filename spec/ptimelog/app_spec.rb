# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::App do
  subject { described_class.new([command, argument].compact) }

  let(:command) { 'show' }
  let(:argument) { 'all' }
  let(:timelog) do
    Ptimelog::Timelog.instance.parse <<~TIMELOG
      2018-03-02 09:51: start **
      2018-03-02 11:40: 12345: prepare deployment -- webapp
      2018-03-02 12:25: lunch **
      2018-03-02 13:15: 23456: debug -- network
      2018-03-02 14:30: break **
      2018-03-02 16:00: handover
      2018-03-02 17:18: cleanup database
      2018-03-02 18:58: dinner **
      2018-03-02 20:08: 12345: prepare deployment -- webapp
    TIMELOG
  end
  let(:config) { {} }

  before :each do
    config.each do |key, value|
      Ptimelog::Configuration.instance[key] = value
    end
  end

  after :each do
    Ptimelog::Configuration.instance.reset
  end

  context 'can show parsed entries' do
    let(:command) { :show }
    let(:argument) { '2018-03-02' }

    it 'on stdout' do
      expect(subject).to receive(:timelog).at_least(:once).and_return(timelog)

      # hides **-entries
      expect { subject.run }.not_to output(/lunch/).to_stdout
      expect { subject.run }.not_to output(/break/).to_stdout
      expect { subject.run }.not_to output(/dinner/).to_stdout

      # show entries without ticket
      expect { subject.run }.to output(/handover/).to_stdout
      expect { subject.run }.to output(/cleanup database/).to_stdout

      # rounds time by default
      expect { subject.run }.to output(/09:45 - 11:45/).to_stdout # rounding 9:41, 11:40 outwards
      expect { subject.run }.to output(/12:30 - 13:15/).to_stdout # rounding 12:25 up
      expect { subject.run }.to output(/14:30 - 16:00/).to_stdout # leaving round values as is
      expect { subject.run }.to output(/16:00 - 17:15/).to_stdout # rounding 17:18 down
      expect { subject.run }.to output(/19:00 - 20:15/).to_stdout # case of 18:60 -> 19:00
    end
  end

  # it 'can upload parsed entries'
  # it 'can load custom mappers for the ordertime_account'
  # it 'can open the timelog in an editor'
  # it 'can open a parser-script in an editor'
end

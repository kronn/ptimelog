# typed: false
# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::App do
  include_context 'mocked timelog'
  subject { described_class.new([command, argument].compact) }

  context 'can show parsed entries' do
    let(:command) { :show }
    let(:argument) { mocked_timelog_date }

    it 'on stdout' do
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

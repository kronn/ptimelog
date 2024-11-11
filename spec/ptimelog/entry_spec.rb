# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Entry do
  context 'has a string representation' do
    subject do
      entry = described_class.new
      entry.start_time  = '10:00'
      entry.finish_time = '11:45'
      entry.date        = '1970-01-01'
      entry.ticket      = '12345'
      entry.description = 'important work'
      entry.tags        = 'client'
      entry
    end

    it 'with the usual method' do
      expect(subject).to respond_to :to_s
    end

    it 'for simple cases' do
      expect(subject.to_s).to eql '10:00 - 11:45 | 1.75h | 12345: important work | client'
    end

    it 'with multiple tags' do
      subject.tags = 'client debugging server'

      expect(subject.to_s).to eql '10:00 - 11:45 | 1.75h | 12345: important work | client debugging server'
    end

    it 'with no tags and no account' do
      subject.tags = nil
      expect(subject.account).to be_nil

      expect(subject.to_s).to eql '10:00 - 11:45 | 1.75h | 12345: important work'
    end

    it 'without a ticket' do
      subject.ticket = nil

      expect(subject.to_s).to eql '10:00 - 11:45 | 1.75h | important work | client'
    end
  end

  context 'rounds entry times to nearest 15 minutes by default' do
    it 'rounding 9:41, 11:40 outwards' do
      subject.start_time  = '09:41'
      subject.finish_time = '11:40'

      expect(subject.to_s).to match(/09:45 - 11:45/)
    end

    it 'rounding 12:25 up' do
      subject.start_time  = '12:25'
      subject.finish_time = '13:15'

      expect(subject.to_s).to match(/12:30 - 13:15/)
    end

    it 'leaving round values as is' do
      subject.start_time  = '14:30'
      subject.finish_time = '16:00'

      expect(subject.to_s).to match(/14:30 - 16:00/)
    end

    it 'rounding 17:18 down' do
      subject.start_time  = '16:00'
      subject.finish_time = '17:18'

      expect(subject.to_s).to match(/16:00 - 17:15/)
    end

    it 'case of 18:60 -> 19:00' do
      subject.start_time  = '18:58'
      subject.finish_time = '20:08'

      expect(subject.to_s).to match(/19:00 - 20:15/)
    end
  end

  context 'can be configured' do
    it 'to not round the time-entries' do
      Ptimelog::Configuration.instance[:rounding] = false

      subject.start_time = '09:51'
      subject.finish_time = '11:40'

      expect(subject.to_s).to match(/09:51 - 11:40/)
    end
  end

  context 'can infer the account-id and billable-state' do
    let(:script_mock) do
      instance_double(
        Ptimelog::Script,
        inferer: fixtures_dir / 'inferer'
      )
    end

    it 'from an external script' do
      output = `#{script_mock.inferer(:mocked)}`
      expect(output).to match(/^1234\ntrue$/m)

      subject.instance_variable_set('@script', script_mock)

      subject.infer_ptime_settings

      expect(subject.account).to eq '1234'
      expect(subject).to be_billable
    end

    it 'if the entry is not hidden' do
      subject.description = 'break **'
      expect(subject).to be_hidden

      subject.infer_ptime_settings

      expect(subject.account).to be_nil
      expect(subject).to_not be_billable
    end
  end

  context 'can compute the duration of an entry' do
    it 'leaving round values as is' do
      subject.start_time  = '14:30'
      subject.finish_time = '16:00'

      expect(subject.duration).to be((90 * 60)) # seconds
    end

    it 'after applying rounding' do
      subject.start_time  = '14:28'
      subject.finish_time = '16:03'

      expect(subject.duration).to be((90 * 60)) # seconds
    end

    it 'with minute-precision if rounding is disabled' do
      Ptimelog::Configuration.instance[:rounding] = false

      subject.start_time  = '15:23'
      subject.finish_time = '15:42'

      expect(subject.duration).to be 1140 # 42 - 23 = 19 minutes in seconds
    end

    it 'but raises if no start_time is set' do
      subject.finish_time = '23:42'

      expect(subject.start_time).to be_nil
      expect(subject.finish_time).to_not be_nil

      expect { subject.duration }.to raise_error TypeError
    end

    it 'but raises if no finish_time is set' do
      subject.start_time = '23:42'

      expect(subject.start_time).to_not be_nil
      expect(subject.finish_time).to be_nil

      expect { subject.duration }.to raise_error TypeError
    end
  end

  context 'are invalid' do
    it 'without start_time' do
      expect(subject.start_time).to be_falsey
      expect(subject).to_not be_valid
    end

    it 'if hidden' do
      subject.description = 'break **'

      expect(subject).to be_hidden
      expect(subject).to_not be_valid
    end

    it 'with a duration of 0' do
      subject.start_time = '13:37'
      subject.finish_time = '13:37'

      expect(subject.duration).to be_zero
      expect(subject).to_not be_valid
    end
  end
end

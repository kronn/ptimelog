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

  context 'can be combined' do
    def timelog(attrs)
      entry = described_class.from_timelog(
        date:        attrs.fetch(:date, Date.today),
        ticket:      attrs.fetch(:ticket, '12345'),
        description: attrs.fetch(:description, 'Work'),
        time:        attrs.fetch(:time, '10:00'),
        tags:        attrs.fetch(:tags, 'test tag')
      )
      entry.start_time = attrs.fetch(:start, '08:00')

      entry
    end

    it 'with the same, non-empty ticket and keep the ticket' do
      one = timelog(ticket: '123')
      two = timelog(ticket: '123')

      result = one + two

      expect(result.ticket).to be '123'
    end

    it 'with the same date and keep the date' do
      one = timelog(date: Date.parse('2025-02-18'))
      two = timelog(date: Date.parse('2025-02-18'))

      result = one + two

      expect(result.date).to eql Date.parse('2025-02-18')
    end

    it 'only with the same date' do
      one = timelog(date: Date.parse('2025-02-18'))
      two = timelog(date: Date.parse('2025-01-01'))

      expect do
        one + two
      end.to raise_error Ptimelog::Entry::AdditionError
    end

    it 'with the same tags' do
      one = timelog(tags: 'test tag')
      two = timelog(tags: 'test tag')

      result = one + two

      expect(result.tags).to match_array %w[test tag]
    end

    it 'if only one has tags' do
      one = timelog(tags: 'test tag')
      two = timelog(tags: '')

      expect((one + two).tags).to match_array %w[test tag]
      expect((two + one).tags).to match_array %w[test tag]
    end

    it 'if both are valid' do
      one = timelog(start: '08:00', time: '10:00')
      two = timelog(start: nil, time: '12:00')

      expect(one).to be_valid
      expect(two).to_not be_valid

      expect do
        one + two
      end.to raise_error(Ptimelog::Entry::AdditionError)
    end

    it 'but rejects differing tags' do
      one = timelog(tags: 'work blub')
      two = timelog(tags: 'work blah')

      expect do
        one + two
      end.to raise_error Ptimelog::Entry::AdditionError
    end

    it 'and combine the description' do
      one = timelog(description: 'Research')
      two = timelog(description: 'Feedback')

      result = one + two

      expect(result.description).to eql 'Research, Feedback'
    end

    it 'and reduces duplication in the description' do
      one = timelog(description: 'Research')
      two = timelog(description: 'Research')

      result = one + two

      expect(result.description).to eql 'Research'
    end

    it 'and have the combined duration' do
      one = timelog(start: '08:00', time: '10:00')
      two = timelog(start: '12:00', time: '14:00')

      two_hours = 2 * 3600

      expect(one.duration).to be(two_hours)
      expect(two.duration).to be(two_hours)

      four_hours = 4 * 3600

      expect((one + two).duration).to be(four_hours)
    end

    it 'and have ptime-settings'
    it 'and combine the start/end-time if possible'
    it 'and conjure new start/end-time if needed'

    it 'only if the ticket is present' do
      one = timelog(ticket: '')
      two = timelog(ticket: '')

      expect(one.ticket).to eql two.ticket

      expect do
        one + two
      end.to raise_error Ptimelog::Entry::AdditionError
    end

    it 'only if the tickets match' do
      one = timelog(ticket: '123')
      two = timelog(ticket: '456')

      expect(one.ticket).to_not eq two.ticket

      expect do
        one + two
      end.to raise_error Ptimelog::Entry::AdditionError
    end

    # commutativity is the only math-assumption I will check here
    # neutral elements are invalid and
    # inverse elements are both invalid and hard to imagine.
    it 'regardless of the order of "addition"'
  end
end

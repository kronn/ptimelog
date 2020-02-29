# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Entry do
  it 'has a string representation' do
    expect(subject).to respond_to :to_s

    subject.start_time  = '10:00'
    subject.finish_time = '11:45'
    subject.date        = '1970-01-01'
    subject.ticket      = '12345'
    subject.description = 'important work'
    subject.tags        = 'client'

    expect(subject.to_s).to eql '10:00 - 11:45 12345 : important work : client'
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
end

# frozen_string_literal: true

require 'spec_helper'

describe Gpuzzletime::Entry do
  it 'has a string representation' do
    expect(subject).to respond_to :to_s

    subject.start_time  = '09:51'
    subject.finish_time = '11:40'
    subject.date        = '1970-01-01'
    subject.ticket      = '12345'
    subject.description = 'important work'
    subject.tags        = 'client'

    expect(subject.to_s).to eql '09:51 - 11:45 12345 : important work : client'
  end

  context 'can be configured' do
    it 'to not round the time-entries' do
      Gpuzzletime::Configuration.instance[:rounding] = false

      subject.start_time = '09:51'
      subject.finish_time = '11:40'

      expect(subject.to_s).to match(/09:51 - 11:40/)
    end
  end
end

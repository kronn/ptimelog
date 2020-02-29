# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Day do
  include_context 'mocked timelog'
  let(:date) { mocked_timelog_date }
  subject { described_class.new(date) }

  it 'has entries' do
    is_expected.to respond_to :entries
  end

  it 'returns entries as Hash of Arrays, grouped by date' do
    entries = subject.entries

    expect(entries).to be_a Hash
    expect(entries.keys).to eq [date]
    expect(entries.fetch(date)).to be_an Array

    entries.fetch(date).each do |entry|
      expect(entry).to be_an Ptimelog::Entry
    end
  end

  context 'all entries' do
    it 'are valid' do
      subject.entries.fetch(date).each do |entry|
        expect(entry).to be_valid
      end
    end

    it 'have a start- and finish-time' do
      subject.entries.fetch(date).each do |entry|
        expect(entry.start_time).to_not be_nil
        expect(entry.start_time).to match(/\A\d{2}:\d{2}\z/)

        expect(entry.finish_time).to_not be_nil
        expect(entry.finish_time).to match(/\A\d{2}:\d{2}\z/)
      end
    end
  end
end

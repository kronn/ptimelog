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

  context 'adjacent simliar entries' do
    let(:timelog) do
      Ptimelog::Timelog.instance.parse <<~TIMELOG
        2018-03-03 14:00: start
        2018-03-03 15:34: 23456: debug -- network
        2018-03-03 16:45: 23456: debug -- network
      TIMELOG
    end

    let(:date) { '2018-03-03' }

    it 'are joined' do
      entries = subject.entries

      expect(entries.keys.size).to eq 1 # day
      expect(entries.first[1].size).to eq 1 # entry

      single_entry = entries.first[1].first

      expect(single_entry.ticket).to eq '23456'
      expect(single_entry.description).to eq 'debug'

      expect(single_entry.start_time).to eq '14:00'
      expect(single_entry.finish_time).to eq '16:45'
      duration_seconds = (60 + 60 + 45) * 60
      expect(single_entry.duration).to be duration_seconds
    end
  end
end

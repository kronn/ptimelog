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
        2018-03-03 11:00: start **
        2018-03-03 12:00: 123: other -- network
        2018-03-03 13:00: lunch **
        2018-03-03 14:00: 123: other -- network
        2018-03-03 14:14: 23456: debug -- network
        2018-03-03 14:43: 23456: debug -- network
        2018-03-03 15:34: 23456: debug -- network
        2018-03-03 15:34: 23456: debug -- network
        2018-03-03 16:45: 23456: debug -- network
        2018-03-03 17:00: 123: other -- network
      TIMELOG
    end

    let(:date) { '2018-03-03' }

    context 'has a join-implementation which' do
      let(:entries) do
        timelog.each_with_object({}) do |(day, lines), hash|
          hash[day] = subject.send(:entries_of_day, lines)
        end.fetch(date)
      end

      it 'has assumptions' do
        expect(entries.size).to be 8
      end

      it 'joins not if one' do
        list = []
        list << entries[0]

        expect(list.size).to be 1

        result = subject.send(:join_similar, list)

        expect(result.size).to be 1
      end

      it 'joins not if two are different' do
        list = []
        list << entries[1]
        list << entries[2]

        expect(list.size).to be 2

        result = subject.send(:join_similar, list)

        expect(result.size).to be 2
      end

      it 'joins nothing if all are different' do
        list = []
        list << entries[0]
        list << entries[2]
        list << entries[6]

        expect(list.size).to be 3

        result = subject.send(:join_similar, list)

        expect(result.size).to be 3
      end

      it 'joins only adjacent entries, even with same description' do
        list = []
        list << entries[2]
        list << entries[3]
        list << entries[5]

        expect(list.size).to be 3

        expect(list.map(&:description).uniq).to be_one
        expect(list.map(&:ticket).uniq).to be_one
        expect(entries[2].finish_time).to eq entries[3].start_time
        expect(entries[3].finish_time).to_not eq entries[3].start_time

        result = subject.send(:join_similar, list)

        expect(result.size).to be 2
      end
    end

    it 'are joined' do
      entries = subject.entries

      expect(entries.keys.size).to eq 1 # day
      expect(entries.first[1].size).to eq 4 # entries

      single_entry = entries.first[1][2]

      expect(single_entry.ticket).to eq '23456'
      expect(single_entry.description).to eq 'debug'

      expect(single_entry.start_time).to eq '14:00'
      expect(single_entry.finish_time).to eq '16:45'
      duration_seconds = (60 + 60 + 45) * 60
      expect(single_entry.duration).to be duration_seconds
    end
  end
end

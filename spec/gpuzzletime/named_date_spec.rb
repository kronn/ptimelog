# frozen_string_literal: true

require 'spec_helper'

describe Gpuzzletime::NamedDate do
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

  it 'knows today by name' do
    today = '2018-03-03'

    Timecop.travel(today) do
      expect(subject.named_date('today')).to eq(today)
    end
  end

  it 'knows yesterday by name' do
    today     = '2018-03-03'
    yesterday = '2018-03-02'

    Timecop.travel(today) do
      expect(subject.named_date('yesterday')).to eq(yesterday)
    end
  end

  it 'knows the last day by name' do
    expect(subject).to receive(:timelog).at_least(:once).and_return(timelog)
    last_day = '2018-03-03' # dependent on test-data of timelog above

    expect(subject.named_date('last')).to eq(last_day)
  end

  it 'understands and accepts dates in YYYY-MM-DD format' do
    date = '1970-01-01'
    expect(subject.named_date(date)).to be date
  end

  xit 'defaults to "last day"'
  xit 'returns :all if nothing was found'
end
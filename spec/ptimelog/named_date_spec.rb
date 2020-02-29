# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::NamedDate do
  include_context 'mocked timelog'

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

  it 'understands and accepts dates in YYYY-MM-DD format' do
    date = '1970-01-01'
    expect(subject.named_date(date)).to be date
  end

  context 'taking the timelog into account' do
    let(:last_day) { mocked_timelog_last_day }

    it 'knows the last day by name' do
      expect(subject.named_date('last')).to eq(last_day)
    end

    it 'defaults to "last day" for nil' do
      expect(subject.date(nil)).to eq(last_day)
    end

    it 'defaults to "last day" for ""' do
      expect(subject.date('')).to eq(last_day)
    end

    it 'returns :all if nothing was found' do
      expect(subject.date('something-unrecognized')).to eq(:all)
    end
  end
end

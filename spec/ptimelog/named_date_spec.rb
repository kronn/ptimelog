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

  context 'weekdays are known by name:' do
    it 'monday' do
      today = '2018-03-05'
      monday = '2018-02-26'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(monday)).to be_monday

      Timecop.travel(today) do
        expect(subject.named_date('monday')).to eq(monday)
      end
    end

    it 'tuesday' do
      today = '2018-03-05'
      tuesday = '2018-02-27'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(tuesday)).to be_tuesday

      Timecop.travel(today) do
        expect(subject.named_date('tuesday')).to eq(tuesday)
      end
    end

    it 'wednesday' do
      today = '2018-03-05'
      wednesday = '2018-02-28'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(wednesday)).to be_wednesday

      Timecop.travel(today) do
        expect(subject.named_date('wednesday')).to eq(wednesday)
      end
    end

    it 'thursday' do
      today = '2018-03-05'
      thursday = '2018-03-01'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(thursday)).to be_thursday

      Timecop.travel(today) do
        expect(subject.named_date('thursday')).to eq(thursday)
      end
    end

    it 'friday' do
      today = '2018-03-05'
      friday = '2018-03-02'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(friday)).to be_friday

      Timecop.travel(today) do
        expect(subject.named_date('friday')).to eq(friday)
      end
    end

    it 'saturday' do
      today = '2018-03-05'
      saturday = '2018-03-03'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(saturday)).to be_saturday

      Timecop.travel(today) do
        expect(subject.named_date('saturday')).to eq(saturday)
      end
    end

    it 'sunday' do
      today = '2018-03-05'
      sunday = '2018-03-04'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(sunday)).to be_sunday

      Timecop.travel(today) do
        expect(subject.named_date('sunday')).to eq(sunday)
      end
    end
  end

  context 'weekdays are known by shortened name:' do
    it 'mon' do
      today = '2018-03-05'
      monday = '2018-02-26'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(monday)).to be_monday

      Timecop.travel(today) do
        expect(subject.named_date('mon')).to eq(monday)
      end
    end

    it 'tue' do
      today = '2018-03-05'
      tuesday = '2018-02-27'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(tuesday)).to be_tuesday

      Timecop.travel(today) do
        expect(subject.named_date('tue')).to eq(tuesday)
      end
    end

    it 'wed' do
      today = '2018-03-05'
      wednesday = '2018-02-28'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(wednesday)).to be_wednesday

      Timecop.travel(today) do
        expect(subject.named_date('wed')).to eq(wednesday)
      end
    end

    it 'thu' do
      today = '2018-03-05'
      thursday = '2018-03-01'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(thursday)).to be_thursday

      Timecop.travel(today) do
        expect(subject.named_date('thu')).to eq(thursday)
      end
    end

    it 'fri' do
      today = '2018-03-05'
      friday = '2018-03-02'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(friday)).to be_friday

      Timecop.travel(today) do
        expect(subject.named_date('fri')).to eq(friday)
      end
    end

    it 'sat' do
      today = '2018-03-05'
      saturday = '2018-03-03'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(saturday)).to be_saturday

      Timecop.travel(today) do
        expect(subject.named_date('sat')).to eq(saturday)
      end
    end

    it 'sun' do
      today = '2018-03-05'
      sunday = '2018-03-04'

      expect(Date.parse(today)).to be_monday
      expect(Date.parse(sunday)).to be_sunday

      Timecop.travel(today) do
        expect(subject.named_date('sun')).to eq(sunday)
      end
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

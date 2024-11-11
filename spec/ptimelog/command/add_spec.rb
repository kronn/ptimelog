# frozen_string_literal: true

require 'spec_helper'

xdescribe Ptimelog::Command::Add do
  subject { described_class.new(task) }
  let(:task) { 'working on stuff' }

  let(:timelog_txt) do
    Pathname.new(fixtures_dir / 'timelog_for_add.txt')
  end

  let(:config) do
    {
      dir:     fixtures_dir / 'empty',
      timelog: timelog_txt.to_s,
    }
  end

  before :each do
    timelog_txt.open('w') do |file|
      file << <<~TIMELOG
        2018-03-05 14:00: start **
        2018-03-05 15:34: 23456: debug -- network
        2018-03-05 18:46: studying
        2018-03-05 20:08: dinner **
        2018-03-05 21:36: 12345: prepare deployment -- webapp

      TIMELOG
    end
  end

  after :each do
    Pathname.new(fixtures_dir / 'timelog_for_add.txt').truncate(0)
  end

  after :all do
    Pathname.new(fixtures_dir / 'timelog_for_add.txt').delete
  end

  it 'does not need existing entries' do
    is_expected.to_not be_needs_entries
  end

  it 'appends the task to the timelog' do
    timelog = Ptimelog::Timelog.instance
    last_date = timelog.load.last.first

    Timecop.travel(last_date.succ) do
      expect(last_date).to eq last_date
      expect(last_date).to_not eq Date.today.to_s

      subject.run

      timelog.instance_variable_set('@load', nil)
      last_date = timelog.load.last.first

      expect(last_date).to eq Date.today.to_s
    end
  end

  it 'appends an empty line if the day changed' do
    timelog = Ptimelog::Timelog.instance
    last_date = timelog.load.last.first

    Timecop.travel(last_date.succ) do
      expect(last_date).to eq last_date
      expect(last_date).to_not eq Date.today.to_s

      subject.run

      last_lines = timelog.timelog_txt.readlines.last(2).map(&:chomp)

      empty_line = /\A\z/
      new_entry  = /\A\d{4}-\d{2}-\d{2} \d{2}:\d{2}: working on stuff\z/

      expect(last_lines.size).to be 2

      expect(last_lines.first).to match(empty_line)
      expect(last_lines.last).to match(new_entry)
    end
  end

  context 'allows slight manipulation of entry,' do
    before { described_class.send(:public, :parse_task) }

    it 'shifting back with a negative prefix like -5' do
      now = Time.local(2020, 11, 30, 10, 30)
      five_minutes = (5 * 60)

      Timecop.travel(now) do
        task_time, task_description = subject.parse_task('-5 working on stuff')

        expect(task_time).to eq (now - five_minutes).strftime('%F %R')
        expect(task_time).to eq Time.local(2020, 11, 30, 10, 25).strftime('%F %R')
        expect(task_description).to eq 'working on stuff'
      end
    end

    it 'shifting forward with a positive prefix like +5' do
      now = Time.local(2020, 11, 30, 10, 30)
      five_minutes = (5 * 60)

      Timecop.travel(now) do
        task_time, task_description = subject.parse_task('+5 working on stuff')

        expect(task_time).to eq (now + five_minutes).strftime('%F %R')
        expect(task_time).to eq Time.local(2020, 11, 30, 10, 35).strftime('%F %R')
        expect(task_description).to eq 'working on stuff'
      end
    end

    it 'setting the exact time with prefixing HH:MM' do
      now = Time.local(2020, 11, 30, 10, 30)

      Timecop.travel(now) do
        task_time, task_description = subject.parse_task('09:42 working on stuff')

        expect(task_time).to eq Time.local(2020, 11, 30, 9, 42).strftime('%F %R')
        expect(task_description).to eq 'working on stuff'
      end
    end

    it 'setting the exact time with prefixing H:MM' do
      now = Time.local(2020, 11, 30, 10, 30)

      Timecop.travel(now) do
        task_time, task_description = subject.parse_task('9:42 working on stuff')

        expect(task_time).to eq Time.local(2020, 11, 30, 9, 42).strftime('%F %R')
        expect(task_description).to eq 'working on stuff'
      end
    end

    it 'setting an offset exact time with prefixing H:MM and offsetting it also' do
      now = Time.local(2020, 11, 30, 10, 30)

      Timecop.travel(now) do
        task_time, task_description = subject.parse_task('9:42 -3 working on stuff')

        expect(task_time).to eq Time.local(2020, 11, 30, 9, 39).strftime('%F %R')
        expect(task_description).to eq 'working on stuff'
      end
    end

    it 'does not work with offset first, time later as (maybe) expected' do
      now = Time.local(2020, 11, 30, 10, 30)

      Timecop.travel(now) do
        task_time, task_description = subject.parse_task('-3 9:42 working on stuff')

        # maybe you expect this...
        expect(task_time).to_not eq Time.local(2020, 11, 30, 9, 39).strftime('%F %R')
        expect(task_description).to_not eq 'working on stuff'

        # but you'll get this.
        expect(task_time).to eq Time.local(2020, 11, 30, 10, 27).strftime('%F %R')
        expect(task_description).to eq '9:42 working on stuff'
      end
    end

    it 'writing the parsed time to the timelog' do
      timelog = Ptimelog::Timelog.instance
      last_date = timelog.load.last.first

      Timecop.travel(last_date.succ) do
        expect(last_date).to eq last_date
        expect(last_date).to_not eq Date.today.to_s

        described_class.new('9:42 -3 working on stuff').run

        last_line = timelog.timelog_txt.readlines.last.chomp
        new_entry = /\A\d{4}-\d{2}-\d{2} 09:39: working on stuff\z/

        expect(last_line).to match(new_entry)
      end
    end
  end
end

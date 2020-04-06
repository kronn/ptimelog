# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Command::Add do
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
end

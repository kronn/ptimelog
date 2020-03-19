# typed: false
# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'ptimelog'
require 'timecop'
require 'pathname'

RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to
  # set it on RSpec 3.
  #
  # It causes the host group and examples to inherit metadata
  # from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'mocked timelog' do
  let(:timelog) do
    Ptimelog::Timelog.instance.parse <<~TIMELOG
      2018-03-02 09:51: start **
      2018-03-02 11:40: 12345: prepare deployment -- webapp
      2018-03-02 12:25: lunch **
      2018-03-02 13:15: 23456: debug -- network
      2018-03-02 14:30: break **
      2018-03-02 16:00: handover
      2018-03-02 17:18: cleanup database
      2018-03-02 18:58: dinner **
      2018-03-02 20:08: 12345: prepare deployment -- webapp

      2018-03-03 14:00: start **
      2018-03-03 15:34: 23456: debug -- network
      2018-03-03 18:46: studying
      2018-03-03 20:08: dinner **
      2018-03-03 21:36: 12345: prepare deployment -- webapp

      2018-03-05 09:00: start **
    TIMELOG
  end
  let(:mocked_timelog_date) { '2018-03-02' }
  let(:mocked_timelog_last_day) { '2018-03-03' }

  before :each do
    allow(Ptimelog::Timelog.instance)
      .to receive(:load).at_least(:once).and_return(timelog)
  end
end

RSpec.shared_context 'configuration reset' do
  let(:config) do
    {
      dir: fixtures_dir / 'empty',
    }
  end

  before :each do
    config.each do |key, value|
      Ptimelog::Configuration.instance[key] = value
    end
  end

  after :each do
    Ptimelog::Configuration.instance.reset
  end
end

RSpec.shared_context 'fixtures dir' do
  def fixtures_dir
    Pathname.new(File.expand_path('./fixtures', __dir__))
  end
end

RSpec.configure do |rspec|
  rspec.include_context 'fixtures dir'
  rspec.include_context 'configuration reset'
end

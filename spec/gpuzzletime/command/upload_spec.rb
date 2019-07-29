# frozen_string_literal: true

require 'spec_helper'

describe Gpuzzletime::Command::Upload do
  subject { described_class.new }

  let(:config) do
    {
      base_url: 'https://puzzletime.example.net',
    }
  end

  before :each do
    Gpuzzletime::Configuration.instance.reset

    config.each do |key, value|
      Gpuzzletime::Configuration.instance[key] = value
    end
  end

  let(:entries) do
    {
      '1970-01-01' => [
        Gpuzzletime::Entry.new,
        Gpuzzletime::Entry.new,
        Gpuzzletime::Entry.new,
        Gpuzzletime::Entry.new,
        Gpuzzletime::Entry.new,
      ],
    }
  end

  before do
    subject.entries = entries
  end

  it 'opens a browser with a configured domain' do
    allow(subject).to receive(:puts).and_return(true)

    expect(subject).to receive(:xdg_open).with(
      %r{https://puzzletime.example.net}, silent: true
    ).exactly(5).times.and_return(true)

    subject.run
  end

  it 'states which date is being uploaded' do
    allow(subject).to receive(:xdg_open).and_return(true)

    expect { subject.run }.to output(/Uploading 1970-01-01/).to_stdout
  end
end

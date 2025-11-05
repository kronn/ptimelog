# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::Obsidian do
  let(:obsidian) { described_class.new('2025-10-22') }
  let(:file_content) { File.read('spec/fixtures/datasources/obsidian-note.md') }

  before do
    Ptimelog::Configuration.instance['dayplanner_heading_level'] = 1
    Ptimelog::Configuration.instance['dayplanner_heading_title'] = 'Calendar'

    allow(obsidian)
      .to receive(:file)
      .and_return(double(read: file_content)) # rubocop:disable RSpec/VerifiedDoubles
  end

  describe '#entries' do
    subject(:entries) { obsidian.entries }

    it 'returns an array of entries' do
      expect(entries).to be_an(Array)
    end

    it 'creates entries with correct start times' do
      expect(entries[0].start_time).to eq('09:00')
      expect(entries[1].start_time).to eq('10:45')
      expect(entries[2].start_time).to eq('13:00')
    end

    it 'creates entries with correct stop times' do
      expect(entries[0].finish_time).to eq('10:45')
      expect(entries[1].finish_time).to eq('11:30')
      expect(entries[2].finish_time).to eq('14:00')
    end

    it 'creates entries with correct tickets' do
      expect(entries[0].ticket).to eq('meeting')
      expect(entries[1].ticket).to eq('meeting')
      expect(entries[2].ticket).to eq('Ticket#23')
    end

    it 'creates entries with correct descriptions' do
      expect(entries[0].description).to eq('client-sync')
      expect(entries[1].description).to eq('maintenance planning')
      expect(entries[2].description).to eq('analysis, feedback')
    end

    it 'creates entries with correct tags' do
      expect(entries[0].tags).to eq(%w[work clientA])
      expect(entries[1].tags).to eq(%w[work maintenance])
      expect(entries[2].tags).to eq(%w[work clientB support])
    end
  end
end

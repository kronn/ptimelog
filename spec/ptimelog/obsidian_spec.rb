# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::Obsidian do
  let(:date) { '2025-10-22' }
  let(:file_content) { File.read('spec/fixtures/datasources/obsidian-note.md') }
  let(:file_double) { instance_double(Pathname, read: file_content, exist?: true) }
  let(:obsidian) do
    described_class.allocate.tap do |obsidian|
      allow(obsidian).to receive(:file).and_return(file_double)
      obsidian.send(:initialize, date)
    end
  end
  let(:hotfix_entry) do
    Ptimelog::Entry.new.tap do |entry|
      entry.date = date
      entry.start_time = '19:00'
      entry.finish_time = '20:00'
      entry.ticket = 'hotfix'
      entry.description = 'Urgent maintenance'
      entry.tags = 'work clientA support'
    end
  end

  before do
    Ptimelog::Configuration.instance['dayplanner_heading_level'] = 1
    Ptimelog::Configuration.instance['dayplanner_heading_title'] = 'Calendar'

    allow(file_double).to receive(:write) # { |content| @written_content = content } # TODO: verify written content?
  end

  describe '#entries' do
    subject(:entries) { obsidian.entries }

    it 'returns a list of entries' do
      expect(entries).to have(6).items
    end

    it 'creates entries with correct start time' do
      expect(entries[0].start_time).to eq('09:00')
      expect(entries[1].start_time).to eq('10:45')
      expect(entries[2].start_time).to eq('13:00')
      expect(entries[5].start_time).to eq('18:00')
    end

    it 'creates entries with correct stop time' do
      expect(entries[0].finish_time).to eq('10:45')
      expect(entries[1].finish_time).to eq('11:30')
      expect(entries[2].finish_time).to eq('14:00')
      expect(entries[5].finish_time).to eq('18:30')
    end

    it 'creates entries with correct ticket' do
      expect(entries[0].ticket).to eq('meeting')
      expect(entries[1].ticket).to eq('meeting')
      expect(entries[2].ticket).to eq('Ticket#23')
      expect(entries[5].ticket).to eq('Ticket#23')
    end

    it 'creates entries with correct description' do
      expect(entries[0].description).to eq('client-sync')
      expect(entries[1].description).to eq('maintenance planning')
      expect(entries[2].description).to eq('analysis, feedback')
      expect(entries[5].description).to eq('feedback')
    end

    it 'creates entries with correct tags' do
      expect(entries[0].tags).to eq(%w[work clientA])
      expect(entries[1].tags).to eq(%w[work maintenance])
      expect(entries[2].tags).to eq(%w[work clientB support])
      expect(entries[5].tags).to eq(%w[work clientB support])
    end
  end

  describe 'parsing and formatting' do
    it 'dayplanner to ptimelog-entry' do
      formatted = '19:00 - 20:00 hotfix: Urgent maintenance -- work clientA support'
      entry = obsidian.send(:dayplanner_to_entry, formatted)

      expect(entry).to eq(hotfix_entry)
    end

    it 'ptimelog-entry to dayplanner' do
      formatted = obsidian.send(:entry_to_dayplanner, hotfix_entry)

      expect(formatted).to eq '19:00 - 20:00 hotfix: Urgent maintenance -- work clientA support'
    end
  end

  describe '#add' do
    context 'when the dayplanner section exists and has a list,' do
      it 'appends the entry' do
        expect do
          obsidian.add(hotfix_entry)
        end.to change { obsidian.entries.size }.by 1
      end
    end

    context 'when the dayplanner section exists, but is empty,' do
      let(:file_content) do
        note = File.read('spec/fixtures/datasources/obsidian-note.md')
        note_lines = note.lines
        note_lines[1..7] = nil # remove the existing entries
        note_lines.join
      end

      it 'start a list with the entry' do
        expect do
          obsidian.add(hotfix_entry)
        end.to change { obsidian.entries.size }.by 1
      end
    end

    context 'when the daily note file does not exist, it' do
      let(:file_double) { instance_double(Pathname, read: '', exist?: false) }

      it 'fails' do
        expect do
          obsidian.add(hotfix_entry)
        end.to raise_error(Ptimelog::Obsidian::HeadingNotFound)
      end
    end

    context 'when the dayplanner heading does not exist in an existing file, it' do
      let(:file_content) do
        note = File.read('spec/fixtures/datasources/obsidian-note.md')
        note_lines = note.lines
        note_lines[0..7] = nil # remove the existing entries and the heading
        note_lines.compact.join
      end

      it 'fails' do
        expect do
          obsidian.add(hotfix_entry)
        end.to raise_error(Ptimelog::Obsidian::HeadingNotFound)
      end
    end
  end

  describe 'side aspects:' do
    context 'when interacting with an obsidian note' do
      it 'does preserve the links' do
        written_content = nil
        allow(file_double).to receive(:write) { |content| written_content = content }

        obsidian.add(hotfix_entry)

        expect(written_content).to include('[[Meeting Notes]]')
        expect(written_content).to include('[[Meeting Notes#Next|Next Steps]]')
      end

      it 'does not escape #' do
        written_content = nil
        allow(file_double).to receive(:write) { |content| written_content = content }

        obsidian.add(hotfix_entry)

        expect(written_content).to include('Ticket#23')
      end
    end
  end
end

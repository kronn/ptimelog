# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::Operon do
  let(:date) { '2026-10-07' }
  let(:operon) { described_class.new(date) }
  let(:entries) { operon.entries }
  let(:descriptions) { entries.map(&:description) }

  before do
    Ptimelog::Configuration.instance['obsidian_vault'] = fixtures_dir / 'datasources' / 'operon-vault'
  end

  # Entries are generated per session, so one task can appear more than once
  def tickets_of(description)
    entries.select { |entry| entry.description == description }.map(&:ticket)
  end

  describe '#entries' do
    it 'creates one entry per tracked session' do
      expect(entries).to all be_a(Ptimelog::Entry)
      expect(entries.size).to eq 8
    end

    it 'counts only the sessions which start on the requested day' do
      # the task tracks three sessions, one of them a day earlier
      expect(descriptions.count('Anpassungen reviewen')).to eq 2
    end

    it 'sorts the entries by start-time' do
      expect(entries.map(&:start_time)).to eq %w[08:00 09:00 10:00 11:00 12:00 14:00 16:00 17:00]
      expect(entries.map(&:finish_time)).to eq %w[09:00 10:00 11:00 12:00 13:00 15:00 17:00 18:00]
    end

    it 'dates every entry after the start of its session' do
      expect(entries.map(&:date).uniq).to eq [date]
    end

    it 'ignores a running timer' do
      expect(descriptions).not_to include 'Wäsche waschen'
    end

    it 'ignores a planned block' do
      expect(descriptions).not_to include '3D-Druck in Auftrag haben'
    end

    it 'ignores archived notes' do
      expect(descriptions).not_to include 'Archivierte Aufgabe mit Zeit'
    end

    it 'ignores the documentation of Operon' do
      expect(descriptions).not_to include(/Dokumentations-Beispiel/, /Ticket#3611755/)
    end

    it 'ignores the lists of the former dayplanner adapter' do
      expect(descriptions).not_to include(/Backup angefordert/)
    end

    it 'reads the text of an inline task as description' do
      expect(descriptions).to include 'Prereview von Upgrade-PR'
    end

    it 'keeps a colon inside an inline tasks description' do
      expect(descriptions).to include 'HIT-12345: Zeug machen'
    end

    it 'reads the filename of a file task as description' do
      expect(descriptions).to include 'Release'
    end

    it 'splits the ptimelog-key into tags' do
      review = entries.select { |entry| entry.description == 'Anpassungen reviewen' }

      expect(review.first.tags).to eq %w[hit sup sww]
    end

    it 'reads the ticket of an inline task' do
      expect(tickets_of('HIT-12345: Zeug machen').uniq).to eq ['HIT-1657']
    end

    it 'takes the ticket from the key, never from the description' do
      # the description starts with 'HIT-12345', the key says 'HIT-1657'
      expect(tickets_of('HIT-12345: Zeug machen')).to all(eq 'HIT-1657')
    end

    it 'reads the ticket of a file task' do
      release = entries.find { |entry| entry.description == 'Release' }

      expect(release.ticket).to eq 'HIT-4711'
    end

    it 'has no ticket when the key is absent' do
      review = entries.find { |entry| entry.description == 'Anpassungen reviewen' }

      expect(review.ticket).to be_nil
    end

    it 'reads a task which has no operonId' do
      expect(descriptions).to include 'Feedback einholen'
    end

    context 'when a task carries no ptimelog-key' do
      let(:invoice) { entries.find { |entry| entry.description == 'Rechnung prüfen' } }

      it 'lists the entry nonetheless' do
        expect(invoice).not_to be_nil
        expect(invoice).to be_valid
      end

      it 'has no tags and therefore no account' do
        expect(invoice.tags).to be_nil
        expect(invoice.account).to be_nil
      end
    end

    context 'with custom keys' do
      let(:zeug) { entries.find { |entry| entry.description == 'HIT-12345: Zeug machen' } }

      it 'reads the ticket from the configured key' do
        Ptimelog::Configuration.instance['operon_custom_keys'] = { 'ticket' => 'operonId' }

        expect(zeug.ticket).to eq 'rmyporf'
      end

      it 'reads the tags for the inferer from the configured key' do
        Ptimelog::Configuration.instance['operon_custom_keys'] = { 'inferer' => 'ticket' }

        expect(zeug.tags).to eq ['HIT-1657']
      end

      it 'keeps the default of a key which is not configured' do
        Ptimelog::Configuration.instance['operon_custom_keys'] = { 'ticket' => 'operonId' }
        review = entries.find { |entry| entry.description == 'Anpassungen reviewen' }

        expect(review.tags).to eq %w[hit sup sww]
      end
    end
  end

  describe '#previous_entry' do
    subject(:previous) { operon.previous_entry }

    context 'when a timer is running that day' do
      it 'continues from the timer, which is later than the last session' do
        expect(previous.finish_time).to eq '18:30'
      end
    end

    context 'when only sessions were tracked that day' do
      let(:operon) { described_class.new('2026-10-06') }

      it 'continues from the last session' do
        expect(previous.finish_time).to eq '15:00'
      end
    end

    context 'when nothing was tracked that day' do
      let(:operon) { described_class.new('2026-10-08') }

      it 'starts at the start of the day' do
        expect(previous.finish_time).to eq '08:00'
      end

      it 'starts at a configured time' do
        Ptimelog::Configuration.instance['operon_start_time'] = '07:30'

        expect(described_class.new('2026-10-08').previous_entry.finish_time).to eq '07:30'
      end
    end

    it 'is hidden, so it is never uploaded' do
      expect(previous).to be_hidden
    end
  end

  describe '#file' do
    it 'has no single file, an entry can come from any note of the vault' do
      expect(operon.file.exist?).to be false
    end
  end

  describe 'when the vault does not exist' do
    before do
      Ptimelog::Configuration.instance['obsidian_vault'] = fixtures_dir / 'nowhere'
    end

    it 'refuses, instead of reporting a day without any time' do
      expect { operon.entries }.to raise_error(described_class::VaultNotFound, /nowhere/)
    end

    it 'refuses on every other question, too' do
      expect { operon.previous_entry }.to raise_error(Ptimelog::Error)
    end
  end
end

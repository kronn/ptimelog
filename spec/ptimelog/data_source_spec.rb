# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::DataSource do
  subject(:data_source) { described_class.new(settings, day) }

  let(:settings) { Ptimelog::Configuration.instance }
  let(:day) { '2026-10-07' }

  describe 'with obsidian as datasource' do
    before do
      settings['obsidian'] = true
      settings['timelog'] = false
      settings['obsidian_vault'] = fixtures_dir / 'datasources' / 'operon-vault'
    end

    it 'reads the time Operon tracked' do
      expect(data_source.backend).to be_a(Ptimelog::Operon)
    end

    it 'groups the entries by day, as every command expects' do
      expect(data_source.entries.keys).to eq [day]
      expect(data_source.entries[day].size).to eq 8
    end

    it 'has no single file, an entry can come from any note' do
      expect(data_source.file).to be_a NullPathname
    end
  end
end

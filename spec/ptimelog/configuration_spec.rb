# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::Configuration do
  subject(:settings) { described_class.instance }

  describe 'obsidian_vault' do
    it 'is expanded into a pathname, so the vault can be globbed' do
      expect(settings['obsidian_vault']).to eq Pathname.new('~/path/to/obsidian-vault').expand_path
    end
  end

  describe 'operon_custom_keys' do
    it 'is read with string-keys, as Operon looks them up by string' do
      config = settings.load_config(fixtures_dir / 'operon_custom_keys.yml')

      expect(config['operon_custom_keys']).to eq('ticket' => 'issue')
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::Configuration do
  subject(:settings) { described_class.instance }

  describe 'obsidian_vault' do
    it 'is expanded into a pathname, so the vault can be globbed' do
      expect(settings['obsidian_vault']).to eq Pathname.new('~/path/to/obsidian-vault').expand_path
    end
  end
end

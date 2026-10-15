# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ptimelog::Command::Info do
  subject(:cmd) { described_class.new }

  context 'with obsidian as datasource' do
    before do
      Ptimelog::Configuration.instance['obsidian'] = true
      Ptimelog::Configuration.instance['operon_custom_keys'] = { 'ticket' => 'issue' }
    end

    it 'shows the custom key which is configured' do
      expect { cmd.execute }.to output(/^\s*ticket:\s+issue$/).to_stdout
    end

    it 'shows the default of a custom key which is not configured, as that is used' do
      expect { cmd.execute }.to output(/^\s*inferer:\s+ptimelog$/).to_stdout
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog do
  it 'has a version number' do
    expect(described_class::VERSION).not_to be nil
  end

  it 'has a descriptive banner' do
    expect(described_class::BANNER).not_to be_nil
    expect(described_class::BANNER).to match(/PuzzleTime/)
  end
end

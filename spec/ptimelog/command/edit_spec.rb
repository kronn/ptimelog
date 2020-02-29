# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Command::Edit do
  subject { described_class.new(file) }
  let(:file) { 'inferer' }

  let(:config) do
    {
      dir:     (fixtures_dir / 'config'),
      timelog: (fixtures_dir / 'timelog.txt'),
    }
  end

  context 'finds the requested filename' do
    it 'timelog.txt if empty' do
      expect(subject.send(:find_file, nil))
        .to eq config[:timelog]
    end
    it 'inferer if present' do
      expect(subject.send(:find_file, 'inferer'))
        .to eq config[:dir] / 'inferers' / 'inferer'
    end

    it 'parser if present' do
      expect(subject.send(:find_file, 'parser'))
        .to eq config[:dir] / 'parsers' / 'parser'
    end
    it 'billable-script if requested' do
      expect(subject.send(:find_file, 'billable'))
        .to eq config[:dir] / 'billable'
    end

    it 'empty inferer if nothing else matches' do
      expect(subject.send(:find_file, 'empty'))
        .to eq config[:dir] / 'inferers' / 'empty'
    end
  end
end

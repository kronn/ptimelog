# frozen_string_literal: true

require 'spec_helper'

xdescribe Ptimelog::Command::Edit do
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
        .to eq config[:timelog_txt]
    end
    it 'inferer if present' do
      expect(subject.send(:find_file, 'inferer'))
        .to eq config[:dir] / 'inferers' / 'inferer'
    end

    it 'empty inferer if nothing else matches' do
      expect(subject.send(:find_file, 'empty'))
        .to eq config[:dir] / 'inferers' / 'empty'
    end
  end
end

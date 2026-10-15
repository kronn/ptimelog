# frozen_string_literal: true

require 'spec_helper'

# xdescribe Ptimelog::Command::Edit do
#   subject { described_class.new(file) }
#   let(:file) { 'inferer' }
#
#   let(:config) do
#     {
#       dir:     (fixtures_dir / 'config'),
#       timelog: (fixtures_dir / 'timelog.txt'),
#     }
#   end
#
#   context 'finds the requested filename' do
#     it 'timelog.txt if empty' do
#       expect(subject.send(:find_file, nil))
#         .to eq config[:timelog_txt]
#     end
#     it 'inferer if present' do
#       expect(subject.send(:find_file, 'inferer'))
#         .to eq config[:dir] / 'inferers' / 'inferer'
#     end
#
#     it 'empty inferer if nothing else matches' do
#       expect(subject.send(:find_file, 'empty'))
#         .to eq config[:dir] / 'inferers' / 'empty'
#     end
#   end
# end

describe Ptimelog::Command::Edit do
  subject(:cmd) { described_class.new }

  describe 'finds the file to edit' do
    context 'with obsidian as datasource' do
      before do
        Ptimelog::Configuration.instance['obsidian'] = true
        Ptimelog::Configuration.instance['timelog'] = false
        Ptimelog::Configuration.instance['obsidian_vault'] = fixtures_dir / 'datasources' / 'operon-vault'
      end

      it 'finds none, so no editor is launched with an empty filename' do
        expect(cmd.send(:find_file, nil)).to be_a(NullPathname)
      end

      it 'explains itself instead of launching an editor' do
        expect { cmd.execute }.to output(/no single file/).to_stdout
      end
    end

    context 'with timelog as datasource' do
      before do
        Ptimelog::Configuration.instance['obsidian'] = false
        Ptimelog::Configuration.instance['timelog'] = true
      end

      it 'finds the timelog, even when the file does not exist yet' do
        expect(cmd.send(:find_file, nil)).to eq Ptimelog::Timelog.timelog_txt
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Script do
  subject { described_class.new(Pathname.new('/path/to/config')) }

  it 'knows were parser-scripts are' do
    expect(subject.parser('project').to_s)
      .to eql '/path/to/config/parsers/project'
  end
  it 'knows were the billable-script is' do
    expect(subject.billable.to_s)
      .to eql '/path/to/config/billable'
  end
  it 'knows where inferer scripts are' do
    expect(subject.inferer('project').to_s)
      .to eql '/path/to/config/inferers/project'
  end
  it 'handles inferers without a name' do
    expect(subject.inferer('')).to be_a Pathname
    expect(subject.inferer('')).to_not exist
  end
  it 'can show a deprecation message' do
    described_class.reset_deprecation_warning!

    expect do
      subject.deprecate(subject.parser('project'))
    end.to output(/DEPRECATION NOTICE.*Support for.*will.*be dropped/m).to_stderr
  end
  it 'shows the deprecation-message only once' do
    described_class.reset_deprecation_warning!

    expect do
      subject.deprecate(subject.parser('project'))
      subject.deprecate(subject.parser('another'))
    end.to output(/(.*Support.*){1}/m).to_stderr
  end
  it 'shows the deprecation-header always' do
    described_class.reset_deprecation_warning!

    expect do
      subject.deprecate(subject.parser('project'))
      subject.deprecate(subject.parser('another'))
    end.to output(%r{(.*DEPRECATION.*parsers/project).*(.*DEPRECATION.*parsers/another)}m).to_stderr
  end
end

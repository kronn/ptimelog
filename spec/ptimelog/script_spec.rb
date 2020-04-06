# frozen_string_literal: true

require 'spec_helper'

describe Ptimelog::Script do
  subject { described_class.new(Pathname.new('/path/to/config')) }

  it 'knows where inferer scripts are' do
    expect(subject.inferer('project').to_s)
      .to eql '/path/to/config/inferers/project'
  end

  it 'handles inferers without a name' do
    expect(subject.inferer('')).to be_a Pathname
    expect(subject.inferer('')).to_not exist
  end
end

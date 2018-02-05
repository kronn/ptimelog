# frozen_string_literal: true

require 'spec_helper'

describe Gpuzzletime do
  it 'has a version number' do
    expect(Gpuzzletime::VERSION).not_to be nil
  end

  it 'has a configurable puzzletime-domain'

  it 'can parse log-entries'
  it 'omits entries ending in two stars'

  it 'knows some dates by relative names'

  it 'can show parsed entries'
  it 'can upload parsed entries'
  it 'omits empty dates'
  it 'can limit entries to one day'

  it 'can load custom mappers for the ordertime_account'
end

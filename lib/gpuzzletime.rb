# frozen_string_literal: true

require 'pathname'

# Wrapper for everything
class Gpuzzletime
  def initialize(*_); end

  def run
    read_file
  end

  private

  def read_file
    Pathname.new('~/.local/share/gtimelog/timelog.txt').expand_path.read
  end
end

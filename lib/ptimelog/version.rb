# frozen_string_literal: true

# the version, following semver
#
# Someone wanted to have documentation, so here goes...
#
# Please note that the version-string is not frozen. Although it of course is,
# because all strings in this file are frozen. That's what the magic comment
# at the top of the file does. :gasp:
#
# What else? Yeah, the VERSION-constant is part of the module Ptimelog because
# that is what is described here.
#
# So, I truly hope you are happy now, that I documented this file properly. For
# any remaining questions, please open an issue or even better a pull-request
# with an improvement. Keep in mind that this is also covered by rspec so I
# expect (pun intended) 100% test-coverage for any additional code.
#
# Without much preparation came the addition of cmdparse to this gem. While
# adding it, it became apparent that a duplication between the gemspec and the
# main executable may exist. In order to avoid this dreadfully duplicated
# description, a constant for this has been added to this module. So, the
# correct subtitle of this documentation-block would be "and a Banner not named
# Bruce."
module Ptimelog
  VERSION = '0.11.0'
  BANNER = 'Move time-entries from gTimelog to PuzzleTime'
end

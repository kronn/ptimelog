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
module Ptimelog
  VERSION = '0.9.0'
end

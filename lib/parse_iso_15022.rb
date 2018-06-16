# frozen_string_literal: true

require 'active_support/core_ext/object'

# Parse ISO 15022: Implements various utility methods for parsing the strings
# present in a SWIFT ISO 15022 message.
# Created June 2018.
# @author Brett Vickers <brett@phillips-vickers.com>
# See LICENSE and README.md for details.
module ParseISO15022
  # @return [String] gem project's root directory
  def self.root
    File.dirname __dir__
  end
end

# frozen_string_literal: true

# Parse ISO 15022: Implements various utility methods for parsing the strings
# present in a SWIFT ISO 15022 message.
# Created June 2018.
# @author Brett Vickers <brett@phillips-vickers.com>
module ParseISO15022

# Tokenizer modules for strings in an ISO 15022 message
module Tokenize
  def self.field(input)
    Format.string(input)
  end
end
end
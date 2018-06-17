# frozen_string_literal: true

require 'active_support/core_ext/object'

# Parse ISO 15022: Implements various utility methods for parsing the strings
# present in a SWIFT ISO 15022 message.
# Created June 2018.
# @author Brett Vickers <brett@phillips-vickers.com>
# See LICENSE and README.md for details.
module ParseISO15022
  SIGN_CHAR = 'N'
  FORMAT_DATE_CHARS = %w[Y M D H M S].freeze
  FORMAT_GROUP_CHARS = %w/[ ] ( ) < >/.freeze
  FORMAT_SPECIAL_CHARS =
    (%w[! n a x y z c e d *] +
     [SIGN_CHAR] + FORMAT_DATE_CHARS + FORMAT_GROUP_CHARS
    ).freeze

  FIELD_TYPE = {
    n: '[0-9]',
    a: '[A-Z]',
    c: '[A-Z0-9]',
    x: "[A-Za-z0-9/-?:().,’+ ]",
    e: '[ ]',
    d: '[0-9,]'
  }.freeze

  # @return [String] gem project's root directory
  def self.root
    File.dirname __dir__
  end

  autoload :Generate,    'parse_iso_15022/generate'
  autoload :Parse,       'parse_iso_15022/parse'
  autoload :Tokenize,    'parse_iso_15022/tokenize'

  # Generate module for manipulating strings in an ISO 15022 message
  module Generate
    autoload :Format,    'parse_iso_15022/generate/format'
  end

  # Parser module for strings in an ISO 15022 message
  module Parse
    autoload :Format,    'parse_iso_15022/parse/format'
  end

  # Tokenizer module for strings in an ISO 15022 message
  module Tokenize
    autoload :Format,    'parse_iso_15022/tokenize/format'
  end
end

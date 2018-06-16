# frozen_string_literal: true

# Parse ISO 15022: Implements various utility methods for parsing the strings
# present in a SWIFT ISO 15022 message.
# Created June 2018.
# @author Brett Vickers <brett@phillips-vickers.com>
module ParseISO15022
# Tokenizer modules for strings in an ISO 15022 message
module Tokenize
  # Tokenize a format string
  module Format
    DIGIT_CHARS = Set.new(%w[0 1 2 3 4 5 6 7 8 9]).freeze
    DIGIT_CHAR = ->(c) { DIGIT_CHARS.member?(c) }

    DATE_FORMAT_CHARS = Set.new(%w[Y M D H M S]).freeze
    DATE_FORMAT_CHAR = ->(c) { DATE_FORMAT_CHARS.member?(c) }.freeze

    def self.string(input)
      tokenize_chars(chars: input.split(''))
    end

    def self.tokenize_chars(chars:, index: 0, tokens: [])
      while index <= chars.length - 1
        token, index = consume_chars(chars, index)
        tokens << token
      end

      tokens
    end

    def self.consume_chars(chars, index)
      case chars[index]
      when DIGIT_CHAR
        digits(chars, index)

      when DATE_FORMAT_CHAR
        date_format(chars, index)

      # Default case - a single character is a token
      else
        [chars[index], index + 1]
      end
    end
    private_class_method :consume_chars

    # String of digits
    def self.digits(chars, start)
      token = chars[start]
      index = start + 1
      rest = chars[start + 1..-1]
      rest.each do |char|
        return [token, index] unless DIGIT_CHAR[char]
        token << char
        index += 1
      end

      [token, index]
    end
    private_class_method :digits

    # String of date format characters
    def self.date_format(chars, start)
      token = chars[start]
      index = start + 1
      rest = chars[start + 1..-1]
      rest.each do |char|
        return [token, index] unless DATE_FORMAT_CHAR[char]
        token << char
        index += 1
      end

      [token, index]
    end
    private_class_method :date_format
  end
end
end

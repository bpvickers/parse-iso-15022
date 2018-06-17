# frozen_string_literal: true

# Parse ISO 15022: Implements various utility methods for parsing the strings
# present in a SWIFT ISO 15022 message.
# Created June 2018.
# @author Brett Vickers <brett@phillips-vickers.com>
module ParseISO15022
# Parser modules for strings in an ISO 15022 message
module Parse
  # Parse format strings
  module Format
    # There are 3 types of group:
    # 1) Optional group - []
    # 2) Capture group - ()
    # 3) Reformat capture group - <>
    GROUP_BRACKET = {
      '[' => ']',
      '(' => ')',
      '<' => '>'
    }.freeze

    GROUP_TYPE = {
      '[' => :optional,
      '(' => :capture,
      '<' => :reformat
    }.freeze

    GROUP_START_CHARS = GROUP_BRACKET.keys.freeze
    GROUP_END_CHARS = GROUP_BRACKET.values.freeze
    GROUP_CHARS = (GROUP_START_CHARS + GROUP_END_CHARS).freeze

    GROUP_START_CHAR = ->(c) { GROUP_BRACKET.key?(c) }.freeze

    GROUP_END_CHARS_SET = Set.new(GROUP_END_CHARS).freeze
    GROUP_END_CHAR = ->(c) { GROUP_END_CHARS_SET.member?(c) }.freeze

    SPECIAL_CHARS = (%w[N ! n a x y z c e d *] + GROUP_CHARS).freeze
    SPECIAL_CHARS_SET = Set.new(SPECIAL_CHARS).freeze
    SPECIAL_CHAR = ->(c) { SPECIAL_CHARS_SET.member?(c) }.freeze

    def self.string(input)
      tokens = Tokenize.format(input)

      { format: parse(tokens: tokens) }
    end

    def self.parse(tokens:, index: 0, output: [])
      # index = start
      while index < tokens.length
        case (token = tokens[index])
        # Hit the end of group token, so pop back up the stack
        when GROUP_END_CHAR
        then return [output, index]

        else
          node, index = token(token, tokens, index)
        end

        output << node
      end

      output
    end

    def self.token(token, tokens, index)
      case token
      when ::Integer then pattern(token, tokens, index)

      when ::Symbol then date_format(token, index)

      when 'N' then [{ sign: :N }, index + 1]

      # Start of a group - e.g., [N]
      when GROUP_START_CHAR then group(token, tokens, index)

        # It's a literal
      else
        literal(token, tokens, index)
      end
    end

    def self.group(token, tokens, index)
      node, index = parse(tokens: tokens, index: index + 1)

      raise 'missing closing bracket ] for optional group' unless tokens[index] == ']'

      [{ group: { type: GROUP_TYPE[token], format: node } }, index + 1]
    end

    def self.pattern(max, tokens, index)
      if tokens[index + 1] == '!'
        index += 1
        length = max..max
      else
        length = 1..max
      end
      char_set = tokens[index += 1].to_sym

      node = { pattern: { length: length, char_set: char_set } }

      [node.freeze, index + 1]
    end

    def self.literal(literal, tokens, index)
      index += 1
      while tokens[index].is_a?(::String) && !SPECIAL_CHAR[tokens[index]]
        literal << tokens[index]
        index += 1
      end

      node = { literal: literal }

      [node.freeze, index]
    end

    def self.date_format(token, index)
      node = { date: token.to_sym }

      [node.freeze, index + 1]
    end
  end
end
end
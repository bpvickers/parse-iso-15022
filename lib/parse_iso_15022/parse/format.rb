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
    # The last two are not part of the ISO 15022 standard, but are used
    # by the format command to extract parts of a field.
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

    GROUP_START_CHAR = ->(c) { GROUP_BRACKET.key?(c) }.freeze

    GROUP_END_CHARS_SET = Set.new(GROUP_END_CHARS).freeze
    GROUP_END_CHAR = ->(c) { GROUP_END_CHARS_SET.member?(c) }.freeze

    SPECIAL_CHARS_SET = Set.new(FORMAT_SPECIAL_CHARS).freeze
    SPECIAL_CHAR = ->(c) { SPECIAL_CHARS_SET.member?(c) }.freeze

    def self.string(input)
      { format: parse(tokens: Tokenize.format(input)).first }
    end

    def self.parse(tokens:, index: 0, output: [])
      # index = start
      while index < tokens.length
        case (token = tokens[index])
        # Hit the end of group token, so pop back up the stack
        when GROUP_END_CHAR then return [output, index]
        else
          node, index = token(token, tokens, index)
        end

        output << node
      end

      [output, index]
    end
    private_class_method :parse

    def self.token(token, tokens, index)
      case token
      # E.g., 3!c, 15d
      when ::Integer then field(token, tokens, index)
      # E.g., :YYYYMMDD
      when ::Symbol then date_format(token, index)
      # E.g., N
      when SIGN_CHAR then [{ sign: SIGN_CHAR.to_sym }, index + 1]
      # Start of a group - e.g., [N], [4!c]
      when GROUP_START_CHAR then group(token, tokens, index)
      # It's a literal
      else
        literal(token, tokens, index)
      end
    end
    private_class_method :token

    def self.group(token, tokens, index)
      node, index = parse(tokens: tokens, index: index + 1)

      check_group_end(start_token: token, end_token: tokens[index])

      [{ group: { type: GROUP_TYPE[token], format: node } }, index + 1]
    end
    private_class_method :group

    def self.check_group_end(start_token:, end_token:)
      return if end_token == GROUP_BRACKET[start_token]

      raise "missing closing bracket #{GROUP_BRACKET[start_token]} for optional group"
    end
    private_class_method :check_group_end

    # E.g., 3!c, 15d
    def self.field(max, tokens, index)
      length, repeat, index = length(max, tokens, index)

      type = tokens[index += 1].to_sym
      raise "invalid character set '#{type}'" unless FIELD_TYPE[type]

      node = if repeat == 1
               { field: { length: length, type: type } }
             else
               { field: { length: length, type: type, repeat: repeat } }
             end
      [node.freeze, index + 1]
    end
    private_class_method :field

    def self.length(max, tokens, index)
      case tokens[index + 1]
      when '!'
      then
        [max..max, 1, index + 1]
      when '*'
      then
        repeat = max
        max = tokens[index + 2]
        [1..max, repeat, index + 2]
      else
        [1..max, 1, index]
      end
    end

    def self.literal(literal, tokens, index)
      index += 1
      while tokens[index].is_a?(::String) && !SPECIAL_CHAR[tokens[index]]
        literal << tokens[index]
        index += 1
      end

      [{ literal: literal }.freeze, index]
    end
    private_class_method :literal

    def self.date_format(token, index)
      node = { date: token.to_sym }

      [node.freeze, index + 1]
    end
    private_class_method :date_format
  end
end
end
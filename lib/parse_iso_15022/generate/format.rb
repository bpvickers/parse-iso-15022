# frozen_string_literal: true

# Parse ISO 15022: Implements various utility methods for parsing the strings
# present in a SWIFT ISO 15022 message.
# Created June 2018.
# @author Brett Vickers <brett@phillips-vickers.com>
module ParseISO15022
# Generate objects for manipulating strings in an ISO 15022 message
module Generate
  # Generate format string regexps
  module Format
    def self.format_proc(field_type)
      ->(min, max) { Regexp.new("\\A#{field_type}{#{min},#{max}}\\z")}.freeze
    end

    def self.pattern(field_type:, min:, max:)
      "#{FIELD_TYPE[field_type]}{#{min},#{max}}"
    end

    FORMAT_PROC =
      FIELD_TYPE.transform_values { |v| format_proc(v) }.freeze

    def self.regexp(input)
      # Compile the format string AST into a lambda proc
      pattern = compile(ast: Parse.format(input))

      Regexp.new("\\A#{pattern}\\z")
    end

    def self.format(format:, value:)
      return unless (match = regexp(format).match(value))

      captures = match.captures.length
      raise 'more than one capture group specified' if captures > 1

      # Return the first capture group if specified
      captures.zero? ? value : match[1]
    end

    def self.compile(ast:, recursive: false)
      pattern = +''
      ast[:format].each do |sub_field|
        key = sub_field.keys[0]
        value = sub_field[key]

        pattern << case key
                   when :literal then value
                   when :field then field(value)
                   when :group then group(value, recursive: recursive)
                   end
      end

      pattern
    end

    def self.field(field)
      length = field[:length]

      pattern(field_type: field[:type], min: length.min, max: length.max)
    end

    def self.group(group, recursive: false)
      case group[:type]
      when :optional
      then optional_group(format: group[:format])
      when :capture, :reformat
      then
        raise 'capture group cannot be inside another capture group' if recursive
        capture_group(format: group[:format])
      else
        raise "invalid group type #{group[:type]}"
      end
    end

    def self.optional_group(ast)
      pattern = compile(ast: ast)

      # Create a non-capturing group and make this optional
      "(?:#{pattern})?"
    end

    def self.capture_group(ast)
      pattern = compile(ast: ast, recursive: true)

      # Create a capture group to extract this sub-substring
      "(#{pattern})"
    end
  end
end
end
# frozen_string_literal: true

describe ParseISO15022::Parse do
  context 'invalid format strings' do
    invalid_test = [
      { string: '4!c//YYYYMMDDHHMMSS[,3n][/[N]HH[MM]',
       exception: RuntimeError,
       message: 'missing closing bracket ] for optional group' },
      { string: '4!c//YYYYMMDDHHMMSS[,3n[/[N]HH[MM]]',
        exception: RuntimeError,
        message: 'missing closing bracket ] for optional group' },
      { string: '<4!c//YYYYMMDDHHMMSS[,3n][/[N]HH[MM]]',
        exception: RuntimeError,
        message: 'missing closing bracket > for optional group' },
      { string: '4!s',
        exception: RuntimeError,
        message: "invalid character set 's'" }
    ]

    describe '.string' do
      invalid_test.each do |test|
        it "rejects the string #{test[:string]}" do
          expect { ParseISO15022::Parse.format(test[:string]) }
            .to raise_error(test[:exception], test[:message])
        end
      end
    end
  end

  context 'valid format strings' do
    valid_tests = [
      { string: '4*35x',
        ast: {
          format: [
            { field: { repeat: 4, length: 1..35, type: :x } }
          ]
        }
      },
      { string: ':4!c//4*35x',
        ast: {
          format: [
            { literal: ':' },
            { field: { length: 4..4, type: :c } },
            { literal: '//' },
            { field: { repeat: 4, length: 1..35, type: :x } }
          ]
        }
      },
      { string: '(35x)[3*35x]',
        ast: {
          format: [
            {
              group: {
                type: :capture,
                format: [{ field: { length: 1..35, type: :x } }]
              }
            },
            {
              group: {
                type: :optional,
                format: [{ field: { repeat: 3, length: 1..35, type: :x } }]
              }
            }
          ]
        }
      },
      { string: '35x(3*35x)',
        ast: {
          format: [
            { field: { length: 1..35, type: :x } },
            {
              group: {
                type: :capture,
                format: [{ field: { repeat: 3, length: 1..35, type: :x } }]
              }
            }
          ]
        }
      },
      { string: '4!c//35x',
        ast: {
          format: [
            { field: { length: 4..4, type: :c } },
            { literal: '//' },
            { field: { length: 1..35, type: :x } }
          ]
        }
      },
      { string: ':4!c//YYYYMMDDHHMMSS',
        ast: {
          format: [
            { literal: ':' },
            { field: { length: 4..4, type: :c } },
            { literal: '//' },
            { date: :YYYYMMDDHHMMSS }
          ]
        }
      },
      { string: ':4!c//[N]3!a15d',
        ast: {
          format: [
            { literal: ':' },
            { field: { length: 4..4, type: :c } },
            { literal: '//' },
            { group:
                { type: :optional,
                  format: [ { sign: :N } ] }
            },
            { field: { length: 3..3, type: :a } },
            { field: { length: 1..15, type: :d } }
          ]
        }
      },
      { string: '4!c/[8c]/4!c',
        ast: {
          format: [
            { field: { length: 4..4, type: :c } },
            { literal: '/' },
            { group:
                { type: :optional,
                  format: [ { field: { length: 1..8, type: :c } } ] }
            },
            { literal: '/' },
            { field: { length: 4..4, type: :c } }
          ]
        }
      },
      { string: '4!c//YYYYMMDDHHMMSS[,3n][/[N]HH[MM]]',
        ast: {
          format: [
            { field: { length: 4..4, type: :c } },
            { literal: '//' },
            { date: :YYYYMMDDHHMMSS },
            { group:
                { type: :optional,
                  format: [
                    { literal: ',' },
                    field: { length: 1..3, type: :n }
                  ]
                }
            },
            { group:
                { type: :optional,
                  format: [
                    { literal: '/' },
                    { group:
                        { type: :optional,
                          format: [
                            { sign: :N }
                          ]
                        }
                    },
                    { date: :HH },
                    { group: { type: :optional, format: [date: :MM] } }
                  ]
                }
            }
          ]
        }
      }
    ]

    describe '.string' do
      valid_tests.each do |test|
        it "parses the string #{test[:string]}" do
          result = ParseISO15022::Parse.format(test[:string])
          expect(result).to eq test[:ast]
        end
      end
    end
  end
end
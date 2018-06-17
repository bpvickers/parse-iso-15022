# frozen_string_literal: true

describe ParseISO15022::Parse do
  valid_tests = [
    { string: ':4!c//35x',
      ast: {
        format: [
          { literal: ':' },
          { pattern: { length: 4..4, char_set: :c } },
          { literal: '//' },
          { pattern: { length: 1..35, char_set: :x } }
        ]
      }
    },
    { string: ':4!c//YYYYMMDDHHMMSS',
      ast: {
        format: [
          { literal: ':' },
          { pattern: { length: 4..4, char_set: :c } },
          { literal: '//' },
          { date: :YYYYMMDDHHMMSS }
        ]
      }
    },
    { string: ':4!c//[N]3!a15d',
      ast: {
        format: [
          { literal: ':' },
          { pattern: { length: 4..4, char_set: :c } },
          { literal: '//' },
          { group:
              { type: :optional,
                format: [ { sign: :N } ] }
          },
          { pattern: { length: 3..3, char_set: :a } },
          { pattern: { length: 1..15, char_set: :d } }
        ]
      }
    },
    { string: '4!c/[8c]/4!c',
      ast: {
        format: [
          { pattern: { length: 4..4, char_set: :c } },
          { literal: '/' },
          { group:
              { type: :optional,
                format: [ { pattern: { length: 1..8, char_set: :c } } ] }
          },
          { literal: '/' },
          { pattern: { length: 4..4, char_set: :c } }
        ]
      }
    },
    { string: '4!c//YYYYMMDDHHMMSS[,3n][/[N]HH[MM]]',
      ast: {
        format: [
          { pattern: { length: 4..4, char_set: :c } },
          { literal: '//' },
          { date: :YYYYMMDDHHMMSS },
          { group:
              { type: :optional,
                format: [
                  { literal: ',' },
                  pattern: { length: 1..3, char_set: :n }
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
        expect(ParseISO15022::Parse.format(test[:string])).to eq test[:ast]
      end
    end
  end
end
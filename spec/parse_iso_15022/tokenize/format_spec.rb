# frozen_string_literal: true

describe ParseISO15022::Tokenize do
  tests = [
    { string: ':4!c//35x',
      tokens: [':', 4, '!', 'c', '/',  '/', 35, 'x'] },
    { string: ':4!c//35',
      tokens: [':', 4, '!', 'c', '/', '/', 35] },
    { string: ':4!c/[8c]/4!c/35x',
      tokens: [':', 4, '!', 'c', '/', '[', 8, 'c', ']', '/', 4, '!', 'c', '/', 35, 'x'] },
    { string: ':4!c//[N]3!a15d',
      tokens: [':', 4, '!', 'c', '/', '/', '[', 'N', ']', 3, '!', 'a', 15, 'd'] },
    { string: ':4!c//YYYYMMDD',
      tokens: [':', 4, '!', 'c', '/', '/', :YYYYMMDD] },
    { string: ':4!c//YYYYMMDDHHMMSS',
      tokens: [':', 4, '!', 'c', '/', '/', :YYYYMMDDHHMMSS] }
  ]

  describe '.string' do
    tests.each do |test|
      it "tokenizes the string #{test[:string]}" do
        expect(ParseISO15022::Tokenize.format(test[:string]))
          .to eq test[:tokens]
      end
    end
  end
end
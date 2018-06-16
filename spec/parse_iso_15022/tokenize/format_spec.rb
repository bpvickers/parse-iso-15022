# frozen_string_literal: true

describe ParseISO15022::Tokenize::Format do

  tests = [
    { string: ':4!c//35x',
      tokens: %w[: 4 ! c / / 35 x] },
    { string: ':4!c//35',
      tokens: %w[: 4 ! c / / 35] },
    { string: ':4!c/[8c]/4!c/35x',
      tokens: %w[: 4 ! c / [ 8 c ] / 4 ! c / 35 x] },
    { string: ':4!c//[N]3!a15d',
      tokens: %w[: 4 ! c / / [ N ] 3 ! a 15 d] },
    { string: ':4!c//YYYYMMDD',
      tokens: %w[: 4 ! c / / YYYYMMDD] },
    { string: ':4!c//YYYYMMDDHHMMSS',
      tokens: %w[: 4 ! c / / YYYYMMDDHHMMSS] },
  ]

  describe '.string' do
    tests.each do |test|
      it "tokenizes the string #{test[:string]}" do
        expect(ParseISO15022::Tokenize::Format.string(test[:string]))
          .to eq test[:tokens]
      end
    end
  end
end
# frozen_string_literal: true

describe ParseISO15022::Generate do
  context 'invalid format strings' do
    invalid_tests = [
      {
        format: '4!c//(35x([35x]))',
        error: RuntimeError,
        message: 'capture group cannot be inside another capture group'
      },
      {
        format: '(4!c)//([35x])',
        string: 'CODE//value',
        error: RuntimeError,
        message: 'more than one capture group specified'
      }
    ]
    invalid_tests.each do |test|
      format = test[:format]
      it "rejects as invalid the format: #{format}" do
        expect { ParseISO15022::Generate.format(format: format, value: test[:string]) }
          .to raise_error(test[:error], test[:message])
      end
    end
  end

  context 'valid format strings' do
    valid_tests = [
      {
        format: '4!c//35x',
        string: 'TYPE//Code',
        match: true
      },
      {
        format: '[4!c]//35x',
        string: 'TYPE//Code',
        match: true
      },
      {
        format: '[4!c]//35x',
        string: '//Code',
        match: true
      },
      {
        format: '4!c//[35x]',
        string: 'TYPE//',
        match: true
      },
      {
        format: '4!c//35x',
        string: 'TYPE/Code',
        match: false
      },
      {
        format: '4!c//35x',
        string: 'type/Code',
        match: false
      },
      {
        format: '4!c//35x',
        string: 'TYP//Code',
        match: false
      },
      {
        format: '4c//35x',
        string: 'TYP//Code',
        match: true
      },
      {
        format: '(4!c)//35x',
        string: 'TYPE//Code',
        sub_field: 'TYPE'
      },
      {
        format: '(4!c)//[35x]',
        string: 'TYPE//',
        sub_field: 'TYPE'
      },
      {
        format: '[4!c]//(35x)',
        string: '//Description',
        sub_field: 'Description'
      }
    ]

    describe '.regexp' do
      valid_tests.each do |test|
        it "generates a regexp for the format: #{test[:format]}" do
          regexp = ParseISO15022::Generate.regexp(test[:format])
          result = regexp.match(test[:string])
          expect(!!result).to eq(test[:match] || !test[:sub_field].nil?)
          if result && test[:sub_field] && result.captures.length == 1
            expect(result[1]).to eq test[:sub_field]
          end
        end
      end
    end

    describe '.format' do
      valid_tests.each do |test|
        value = test[:string]
        format = test[:format]
        it "formats the string '#{value}' using the format: #{format}" do
          result = ParseISO15022::Generate.format(format: format, value: value)
          expected = if test[:match] || test[:sub_field]
                       test[:sub_field] || test[:string]
                     end
          expect(result).to eq expected
        end
      end
    end
  end
end
# frozen_string_literal: true

describe ParseISO15022 do
  describe '.root' do
    specify { expect(ParseISO15022.root).to eq File.dirname __dir__ }
  end
end
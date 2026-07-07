# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfFmt do
  describe '.hello' do
    it 'returns cpf-fmt' do
      expect(CpfFmt.hello).to eq('cpf-fmt')
    end
  end
end

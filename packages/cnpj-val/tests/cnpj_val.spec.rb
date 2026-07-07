# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjVal do
  describe '.hello' do
    it 'returns cnpj-val' do
      expect(CnpjVal.hello).to eq('cnpj-val')
    end
  end
end

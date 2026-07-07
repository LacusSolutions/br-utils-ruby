# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjGen do
  describe '.hello' do
    it 'returns cnpj-gen' do
      expect(CnpjGen.hello).to eq('cnpj-gen')
    end
  end
end

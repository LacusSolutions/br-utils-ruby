# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjDV do
  describe '.hello' do
    it 'returns cnpj-dv' do
      expect(CnpjDV.hello).to eq('cnpj-dv')
    end
  end
end

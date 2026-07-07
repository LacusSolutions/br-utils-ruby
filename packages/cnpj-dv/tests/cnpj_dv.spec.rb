# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjDv do
  describe '.hello' do
    it 'returns cnpj-dv' do
      expect(CnpjDv.hello).to eq('cnpj-dv')
    end
  end
end

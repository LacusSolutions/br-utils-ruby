# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjFmt do
  describe '.hello' do
    it 'returns cnpj-fmt' do
      expect(CnpjFmt.hello).to eq('cnpj-fmt')
    end
  end
end

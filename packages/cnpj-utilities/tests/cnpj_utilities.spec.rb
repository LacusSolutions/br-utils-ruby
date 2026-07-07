# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjUtils do
  describe '.hello' do
    it 'returns cnpj-utils' do
      expect(CnpjUtils.hello).to eq('cnpj-utils')
    end
  end
end

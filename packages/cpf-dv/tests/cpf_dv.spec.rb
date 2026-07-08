# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfDV do
  describe '.hello' do
    it 'returns cpf-dv' do
      expect(CpfDV.hello).to eq('cpf-dv')
    end
  end
end

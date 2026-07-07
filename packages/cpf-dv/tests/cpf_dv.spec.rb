# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfDv do
  describe '.hello' do
    it 'returns cpf-dv' do
      expect(CpfDv.hello).to eq('cpf-dv')
    end
  end
end

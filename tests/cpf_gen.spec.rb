# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfGen do
  describe '.hello' do
    it 'returns cpf-gen' do
      expect(CpfGen.hello).to eq('cpf-gen')
    end
  end
end

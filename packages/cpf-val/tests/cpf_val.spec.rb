# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfVal do
  describe '.hello' do
    it 'returns cpf-val' do
      expect(CpfVal.hello).to eq('cpf-val')
    end
  end
end

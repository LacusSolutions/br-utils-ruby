# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CpfUtils do
  describe '.hello' do
    it 'returns cpf-utils' do
      expect(CpfUtils.hello).to eq('cpf-utils')
    end
  end
end

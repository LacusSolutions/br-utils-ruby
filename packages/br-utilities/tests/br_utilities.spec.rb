# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BrUtils do
  describe '.hello' do
    it 'returns br-utilities' do
      expect(BrUtils.hello).to eq('br-utilities')
    end
  end
end

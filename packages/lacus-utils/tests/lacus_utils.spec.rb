# frozen_string_literal: true

require 'spec_helper'

RSpec.describe LacusUtils do
  describe '.hello' do
    it 'returns lacus-utils' do
      expect(LacusUtils.hello).to eq('lacus-utils')
    end
  end
end

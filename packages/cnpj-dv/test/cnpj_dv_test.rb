# frozen_string_literal: true

require 'minitest/autorun'
require 'cnpj-dv'

class CnpjDvTest < Minitest::Test
  def test_hello
    assert_equal 'cnpj-dv', CnpjDv.hello
  end
end

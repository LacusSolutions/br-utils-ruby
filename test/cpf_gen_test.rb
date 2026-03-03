# frozen_string_literal: true

require 'minitest/autorun'
require 'cpf-gen'

class CpfGenTest < Minitest::Test
  def test_hello
    assert_equal 'cpf-gen', CpfGen.hello
  end
end

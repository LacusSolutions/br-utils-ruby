# frozen_string_literal: true

require 'minitest/autorun'
require 'cpf-fmt'

class CpfFmtTest < Minitest::Test
  def test_hello
    assert_equal 'cpf-fmt', CpfFmt.hello
  end
end

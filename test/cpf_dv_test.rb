# frozen_string_literal: true

require "minitest/autorun"
require "cpf-dv"

class CpfDvTest < Minitest::Test
  def test_hello
    assert_equal "cpf-dv", CpfDv.hello
  end
end

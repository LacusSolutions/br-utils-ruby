# frozen_string_literal: true

require "minitest/autorun"
require "cpf-val"

class CpfValTest < Minitest::Test
  def test_hello
    assert_equal "cpf-val", CpfVal.hello
  end
end

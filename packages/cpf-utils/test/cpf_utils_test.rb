# frozen_string_literal: true

require "minitest/autorun"
require "cpf-utils"

class CpfUtilsTest < Minitest::Test
  def test_hello
    assert_equal "cpf-utils", CpfUtils.hello
  end
end

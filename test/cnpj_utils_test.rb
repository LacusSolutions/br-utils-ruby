# frozen_string_literal: true

require "minitest/autorun"
require "cnpj-utilities"

class CnpjUtilsTest < Minitest::Test
  def test_hello
    assert_equal "cnpj-utils", CnpjUtils.hello
  end
end

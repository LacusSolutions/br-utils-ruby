# frozen_string_literal: true

require "minitest/autorun"
require "cnpj-fmt"

class CnpjFmtTest < Minitest::Test
  def test_hello
    assert_equal "cnpj-fmt", CnpjFmt.hello
  end
end

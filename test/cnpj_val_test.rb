# frozen_string_literal: true

require "minitest/autorun"
require "cnpj-val"

class CnpjValTest < Minitest::Test
  def test_hello
    assert_equal "cnpj-val", CnpjVal.hello
  end
end

# frozen_string_literal: true

require "minitest/autorun"
require "cnpj-gen"

class CnpjGenTest < Minitest::Test
  def test_hello
    assert_equal "cnpj-gen", CnpjGen.hello
  end
end

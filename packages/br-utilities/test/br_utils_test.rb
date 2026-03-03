# frozen_string_literal: true

require "minitest/autorun"
require "br-utilities"

class BrUtilsTest < Minitest::Test
  def test_hello
    assert_equal "br-utilities", BrUtils.hello
  end
end

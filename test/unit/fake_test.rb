require 'base_unit_test'
require 'net/http'

class FakeTest < BaseUnitTest
  include TestHelper

  def test_fake
    assert_equal "true", "true"
  end
end

require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    user = users(:one)

    sign_in user
    get home_index_url
    assert_response :success
  end
end

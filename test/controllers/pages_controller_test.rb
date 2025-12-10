require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
    sign_in @user
  end

  test "should get calendar" do
    get calendar_url
    assert_response :success
  end

  test "should get habits" do
    get habits_url
    assert_response :success
  end

  test "should get account" do
    get account_url
    assert_response :success
  end

  test "should get manage" do
    get manage_url
    assert_response :success
  end
end

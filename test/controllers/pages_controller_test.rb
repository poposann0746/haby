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

  test "should get todays_habits" do
    get todays_habits_url
    assert_response :success
  end

  test "todays_habits displays incomplete and completed sections" do
    get todays_habits_url
    assert_response :success
    assert_select ".todays-habits-page"
  end

  test "todays_habits requires authentication" do
    sign_out @user
    get todays_habits_url
    assert_response :redirect
  end
end

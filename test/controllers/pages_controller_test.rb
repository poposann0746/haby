require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get calendar" do
    get pages_calendar_url
    assert_response :success
  end

  test "should get habits" do
    get pages_habits_url
    assert_response :success
  end

  test "should get account" do
    get pages_account_url
    assert_response :success
  end

  test "should get manage" do
    get pages_manage_url
    assert_response :success
  end
end

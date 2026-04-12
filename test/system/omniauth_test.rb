require "application_system_test_case"

class OmniauthSystemTest < ApplicationSystemTestCase
  test "login page shows Google login button" do
    visit new_user_session_path
    assert_selector ".auth-sns-button--google"
    assert_text "Googleでログイン"
  end

  test "registration page shows Google login button" do
    visit new_user_registration_path
    assert_selector ".auth-sns-button--google"
    assert_text "Googleでログイン"
  end

  test "sns user account page hides password change link" do
    google_user = users(:google_user)
    sign_in google_user
    visit account_path
    assert_no_text "パスワードを変更"
    assert_text "Googleアカウントで連携中"
  end

  test "normal user account page shows password change link" do
    user = users(:one)
    sign_in user
    visit account_path
    assert_text "パスワードを変更"
    assert_no_text "Googleアカウントで連携中"
  end

  private

  def sign_in(user)
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: "password"
    click_button "ログイン"
  end
end

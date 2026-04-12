require "test_helper"

class OmniauthTest < ActionDispatch::IntegrationTest
  def mock_google_auth(email: "integration@gmail.com", name: "テスト太郎", uid: "integration-test-uid")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name }
    )
  end

  setup do
    mock_google_auth
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    Rails.application.env_config["omniauth.auth"] = nil
  end

  test "google callback creates user and signs in" do
    assert_difference "User.count", 1 do
      get "/users/auth/google_oauth2/callback"
    end
    assert_response :redirect
    follow_redirect!
    assert flash[:notice].present?
  end

  test "google callback with existing user signs in without creating new user" do
    get "/users/auth/google_oauth2/callback"
    delete destroy_user_session_path

    assert_no_difference "User.count" do
      get "/users/auth/google_oauth2/callback"
    end
    assert_response :redirect
  end

  test "failed authentication redirects to login page" do
    Rails.application.env_config["omniauth.auth"] = nil
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
    # OmniAuth failure はミドルウェアで処理されるため、
    # コントローラーの failure メソッドを直接テスト
    get user_google_oauth2_omniauth_callback_path
    assert_redirected_to new_user_session_path
  end
end

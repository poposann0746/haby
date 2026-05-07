require "rails_helper"

RSpec.describe "OmniAuth", type: :request do
  describe "Google OAuth2 コールバック" do
    it "新規ユーザーを作成してサインインする" do
      mock_google_auth(email: "newuser@gmail.com", name: "新規ユーザー", uid: "new-uid")
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

      expect {
        get user_google_oauth2_omniauth_callback_path
      }.to change(User, :count).by(1)
      expect(response).to redirect_to(habits_path)
    end

    it "既存ユーザーは新規作成せずサインインする" do
      create(:user, :google, email: "existing@gmail.com", uid: "existing-uid")
      mock_google_auth(email: "existing@gmail.com", name: "既存ユーザー", uid: "existing-uid")
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:google_oauth2]

      expect {
        get user_google_oauth2_omniauth_callback_path
      }.not_to change(User, :count)
      expect(response).to redirect_to(habits_path)
    end

    it "認証失敗時はログインページにリダイレクトする" do
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      get user_google_oauth2_omniauth_callback_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

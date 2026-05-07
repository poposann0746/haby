require "rails_helper"

RSpec.describe "UserRememberMe", type: :request do
  let(:user) { create(:user) }

  describe "ログインフォーム" do
    it "ログイン状態保持チェックボックスが表示される" do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('name="user[remember_me]"')
      expect(response.body).to include("ログイン状態を保持する")
    end
  end

  describe "remember_me有効でログイン" do
    it "remember_user_tokenクッキーが設定される" do
      post user_session_path, params: {
        user: { email: user.email, password: "password", remember_me: "1" }
      }
      expect(response).to redirect_to(habits_path)
      follow_redirect!
      expect(cookies["remember_user_token"]).to be_present
    end

    it "remember_created_atが設定される" do
      expect(user.remember_created_at).to be_nil

      post user_session_path, params: {
        user: { email: user.email, password: "password", remember_me: "1" }
      }
      expect(user.reload.remember_created_at).to be_present
    end
  end

  describe "remember_me無効でログイン" do
    it "remember_user_tokenクッキーが設定されない" do
      post user_session_path, params: {
        user: { email: user.email, password: "password", remember_me: "0" }
      }
      expect(response).to redirect_to(habits_path)
      follow_redirect!
      expect(cookies["remember_user_token"]).to be_blank
    end
  end

  describe "ログアウト" do
    it "remember_user_tokenクッキーがクリアされる" do
      post user_session_path, params: {
        user: { email: user.email, password: "password", remember_me: "1" }
      }
      follow_redirect!
      expect(cookies["remember_user_token"]).to be_present

      delete destroy_user_session_path
      follow_redirect!
      expect(cookies["remember_user_token"]).to be_blank
    end
  end
end

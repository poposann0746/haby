require "rails_helper"

RSpec.describe "Pages", type: :request do
  let(:user) { create(:user) }
  let(:sns_user) { create(:user, :google) }

  describe "GET /calendar" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get calendar_path
      expect(response).to have_http_status(:ok)
    end

    it "start_dateパラメータを指定できる" do
      get calendar_path, params: { start_date: "2026-03-01" }
      expect(response).to have_http_status(:ok)
    end

    it "未認証ユーザーはリダイレクトされる" do
      sign_out user
      get calendar_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /todays_habits" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get todays_habits_path
      expect(response).to have_http_status(:ok)
    end

    it "習慣がある場合、セクションが表示される" do
      create(:habit, user: user, schedule_days: [])
      get todays_habits_path
      expect(response.body).to include("todays-habits-section")
    end

    it "未認証ユーザーはリダイレクトされる" do
      sign_out user
      get todays_habits_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "GET /account" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get account_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /manage" do
    before { sign_in user }

    it "正常にレスポンスを返す" do
      get manage_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "名前変更" do
    before { sign_in user }

    it "GET /account/name/edit が正常にレスポンスを返す" do
      get edit_account_name_path
      expect(response).to have_http_status(:ok)
    end

    it "PATCH /account/name で名前を更新できる" do
      patch account_name_path, params: { user: { name: "新しい名前" } }
      expect(response).to redirect_to(account_path)
      expect(user.reload.name).to eq("新しい名前")
    end

    it "無効な名前では更新できない" do
      patch account_name_path, params: { user: { name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "メールアドレス変更" do
    context "通常ユーザー" do
      before { sign_in user }

      it "GET /account/email/edit が正常にレスポンスを返す" do
        get edit_account_email_path
        expect(response).to have_http_status(:ok)
      end

      it "現在のパスワード付きでメールアドレスを更新できる" do
        patch account_email_path, params: {
          user: { email: "new@example.com", current_password: "password" }
        }
        expect(response).to redirect_to(account_path)
        expect(user.reload.email).to eq("new@example.com")
      end

      it "パスワードなしではメールアドレスを更新できない" do
        patch account_email_path, params: {
          user: { email: "new@example.com", current_password: "" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "SNSユーザー" do
      before { sign_in sns_user }

      it "パスワードなしでメールアドレスを更新できる" do
        patch account_email_path, params: {
          user: { email: "newsns@example.com" }
        }
        expect(response).to redirect_to(account_path)
        expect(sns_user.reload.email).to eq("newsns@example.com")
      end
    end
  end

  describe "パスワード変更" do
    context "通常ユーザー" do
      before { sign_in user }

      it "GET /account/password/edit が正常にレスポンスを返す" do
        get edit_account_password_path
        expect(response).to have_http_status(:ok)
      end

      it "パスワードを更新できる" do
        patch account_password_path, params: {
          user: {
            current_password: "password",
            password: "newpassword",
            password_confirmation: "newpassword"
          }
        }
        expect(response).to redirect_to(account_path)
      end
    end

    context "SNSユーザー" do
      before { sign_in sns_user }

      it "パスワード変更ページにアクセスするとリダイレクトされる" do
        get edit_account_password_path
        expect(response).to redirect_to(account_path)
      end

      it "パスワード更新を試みるとリダイレクトされる" do
        patch account_password_path, params: {
          user: { current_password: "x", password: "new", password_confirmation: "new" }
        }
        expect(response).to redirect_to(account_path)
      end
    end
  end

  describe "アカウント削除" do
    before { sign_in user }

    it "GET /account/delete が正常にレスポンスを返す" do
      get confirm_delete_account_path
      expect(response).to have_http_status(:ok)
    end

    it "DELETE /account でアカウントを削除してリダイレクトする" do
      expect {
        delete destroy_account_path
      }.to change(User, :count).by(-1)
      expect(response).to redirect_to(root_path)
    end
  end
end

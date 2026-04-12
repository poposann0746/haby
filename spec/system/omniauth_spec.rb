require "rails_helper"

RSpec.describe "OmniAuth UI", type: :system do
  describe "ログインページ" do
    it "Googleログインボタンが表示される" do
      visit new_user_session_path
      expect(page).to have_css(".auth-sns-button--google")
      expect(page).to have_text("Googleでログイン")
    end
  end

  describe "新規登録ページ" do
    it "Googleログインボタンが表示される" do
      visit new_user_registration_path
      expect(page).to have_css(".auth-sns-button--google")
      expect(page).to have_text("Googleでログイン")
    end
  end

  describe "SNSユーザーのアカウントページ" do
    it "パスワード変更リンクが非表示で、Google連携中が表示される" do
      google_user = create(:user, :google)
      login_as(google_user, scope: :user)
      visit account_path
      expect(page).not_to have_text("パスワードを変更")
      expect(page).to have_text("Googleアカウントで連携中")
    end
  end

  describe "通常ユーザーのアカウントページ" do
    it "パスワード変更リンクが表示される" do
      user = create(:user)
      login_as(user, scope: :user)
      visit account_path
      expect(page).to have_text("パスワードを変更")
      expect(page).not_to have_text("Googleアカウントで連携中")
    end
  end
end

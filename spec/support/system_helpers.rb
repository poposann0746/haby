module SystemHelpers
  def sign_in_via_form(user, password: "password")
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: password
    click_button "ログイン"
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
end

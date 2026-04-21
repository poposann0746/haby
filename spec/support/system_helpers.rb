module SystemHelpers
  def sign_in_via_form(user, password: "password")
    visit new_user_session_path
    fill_in "メールアドレス", with: user.email
    fill_in "パスワード", with: password
    click_button "ログイン"
    expect(page).not_to have_current_path(new_user_session_path)
  end
end

RSpec.configure do |config|
  config.include SystemHelpers, type: :system
  config.include Warden::Test::Helpers, type: :system

  config.after(:each, type: :system) do
    Warden.test_reset!
  end
end

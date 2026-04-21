module OmniauthHelpers
  def mock_google_auth(email: "test@gmail.com", name: "テスト太郎", uid: "test-uid")
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name }
    )
  end
end

RSpec.configure do |config|
  config.include OmniauthHelpers

  config.before(:each) do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
  end
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "from_omniauth creates new user from google auth" do
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new-google-uid",
      info: { email: "newuser@gmail.com", name: "新規ユーザー" }
    )

    assert_difference "User.count", 1 do
      user = User.from_omniauth(auth)
      assert user.persisted?
      assert_equal "google_oauth2", user.provider
      assert_equal "new-google-uid", user.uid
      assert_equal "newuser@gmail.com", user.email
      assert_equal "新規ユーザー", user.name
    end
  end

  test "from_omniauth finds existing user by provider and uid" do
    google_user = users(:google_user)
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-uid-123",
      info: { email: "google@example.com", name: "Googleユーザー" }
    )

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal google_user.id, user.id
    end
  end

  test "from_omniauth links to existing email user" do
    existing = users(:one)
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "new-uid-999",
      info: { email: existing.email, name: existing.name }
    )

    assert_no_difference "User.count" do
      user = User.from_omniauth(auth)
      assert_equal existing.id, user.id
      assert_equal "google_oauth2", user.reload.provider
      assert_equal "new-uid-999", user.uid
    end
  end

  test "sns user does not require password" do
    user = User.new(
      name: "SNSユーザー",
      email: "sns-new@example.com",
      provider: "google_oauth2",
      uid: "test-uid-456",
      password: Devise.friendly_token[0, 20]
    )
    assert user.valid?
  end
end

require "rails_helper"

RSpec.describe User, type: :model do
  describe "アソシエーション" do
    it { is_expected.to have_many(:habits).dependent(:destroy) }
    it { is_expected.to have_many(:habit_logs).dependent(:destroy) }
  end

  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(50) }
  end

  describe "#password_required?" do
    it "SNSユーザーはパスワード不要" do
      user = build(:user, :google)
      expect(user).to be_valid
    end

    it "通常ユーザーはパスワードが必要" do
      user = build(:user, password: nil, password_confirmation: nil)
      expect(user).not_to be_valid
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "new-google-uid",
        info: { email: "newuser@gmail.com", name: "新規ユーザー" }
      )
    end

    it "新規ユーザーを作成する" do
      expect { User.from_omniauth(auth) }.to change(User, :count).by(1)

      user = User.last
      expect(user.provider).to eq("google_oauth2")
      expect(user.uid).to eq("new-google-uid")
      expect(user.email).to eq("newuser@gmail.com")
      expect(user.name).to eq("新規ユーザー")
    end

    it "既存のSNSユーザーをprovider+uidで検索する" do
      existing = create(:user, :google, email: "google@example.com", uid: "google-uid-123")
      auth = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "google-uid-123",
        info: { email: "google@example.com", name: "Googleユーザー" }
      )

      expect { User.from_omniauth(auth) }.not_to change(User, :count)
      expect(User.from_omniauth(auth).id).to eq(existing.id)
    end

    it "既存の通常ユーザーにSNS情報を紐付ける" do
      existing = create(:user, email: "existing@example.com", name: "既存ユーザー")
      auth = OmniAuth::AuthHash.new(
        provider: "google_oauth2",
        uid: "new-uid-999",
        info: { email: "existing@example.com", name: "既存ユーザー" }
      )

      expect { User.from_omniauth(auth) }.not_to change(User, :count)

      user = User.from_omniauth(auth)
      expect(user.id).to eq(existing.id)
      expect(user.reload.provider).to eq("google_oauth2")
      expect(user.uid).to eq("new-uid-999")
    end
  end
end

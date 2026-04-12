require "rails_helper"

RSpec.describe Contact, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_length_of(:message).is_at_most(5000) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }

    it "名前が空でもバリデーション通過する" do
      contact = build(:contact, name: "")
      expect(contact).to be_valid
    end

    it "正しいメールアドレス形式を受け入れる" do
      contact = build(:contact, email: "valid@example.com")
      expect(contact).to be_valid
    end

    it "不正なメールアドレス形式を拒否する" do
      contact = build(:contact, email: "invalid-email")
      expect(contact).not_to be_valid
    end
  end
end

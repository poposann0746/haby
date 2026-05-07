require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  describe "#admin_notification" do
    let(:contact) { build(:contact, name: "Saki", email: "saki@example.com", message: "お問い合わせ") }
    let(:mail) { ContactMailer.admin_notification(contact) }

    it "正しい件名で送信される" do
      expect(mail.subject).to eq("[haby] 新しいお問い合わせがありました")
    end

    it "正しい宛先に送信される" do
      expect(mail.to).to eq([ ENV.fetch("ADMIN_EMAIL") ])
    end

    it "正しい差出人で送信される" do
      expect(mail.from).to eq([ ENV.fetch("MAIL_FROM", "no-reply@yourhaby.com") ])
    end

    it "本文にお問い合わせ内容が含まれる" do
      body =
        if mail.multipart?
          mail.text_part&.decoded || mail.html_part&.decoded || mail.body.decoded
        else
          mail.body.decoded
        end

      expect(body).to include("Saki")
      expect(body).to include("saki@example.com")
      expect(body).to include("お問い合わせ")
    end
  end
end

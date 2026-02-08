require "test_helper"

class ContactMailerTest < ActionMailer::TestCase
  test "admin_notification" do
    contact = Contact.new(
      name: "Saki",
      email: "saki@example.com",
      message: "お問い合わせ"
    )

    mail = ContactMailer.admin_notification(contact)

    assert_equal "[haby] 新しいお問い合わせがありました", mail.subject
    assert_equal [ENV.fetch("ADMIN_EMAIL")], mail.to
    assert_equal [ENV.fetch("MAIL_FROM", "no-reply@yourhaby.com")], mail.from

    # multipartメールなので、textパート（なければbody）をデコードして検証する
    body =
      if mail.multipart?
        mail.text_part&.decoded || mail.html_part&.decoded || mail.body.decoded
      else
        mail.body.decoded
      end

    assert_includes body, "Saki"
    assert_includes body, "saki@example.com"
    assert_includes body, "お問い合わせ"
  end
end

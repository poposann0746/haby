class ContactMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contact_mailer.admin_notification.subject
  #
  def admin_notification(contact)
    @contact = contact

    mail(
      to: ENV.fetch("ADMIN_EMAIL"),
      subject: "[haby] 新しいお問い合わせがありました"
    )
  end
end

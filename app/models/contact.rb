class Contact < ApplicationRecord
  validates :name, length: { maximum: 100 }, allow_blank: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 5000 }
end

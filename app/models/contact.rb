class Contact < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }, no_html_tags: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :message, presence: true, length: { maximum: 5000 }, no_html_tags: true
end

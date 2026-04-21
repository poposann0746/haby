class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  validates :name, presence: true, length: { maximum: 50 }, no_html_tags: true

  has_many :habits, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  def password_required?
    super && provider.blank?
  end

  def self.from_omniauth(auth)
    # provider + uid で既存SNSユーザーを検索
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # メールアドレスで既存通常ユーザーを検索し、SNS情報を紐付け
    if auth.info.email.present?
      user = find_by(email: auth.info.email)
      if user
        user.update!(provider: auth.provider, uid: auth.uid)
        return user
      end
    end

    # 新規ユーザー作成
    create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      name: auth.info.name || "ユーザー",
      password: Devise.friendly_token[0, 20]
    )
  end
end

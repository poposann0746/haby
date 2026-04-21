FactoryBot.define do
  factory :contact do
    name { "テスト太郎" }
    email { "test@example.com" }
    message { "お問い合わせ内容です" }
  end
end

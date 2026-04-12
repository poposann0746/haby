FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "テストユーザー" }
    password { "password" }
    password_confirmation { "password" }

    trait :google do
      provider { "google_oauth2" }
      sequence(:uid) { |n| "google-uid-#{n}" }
      password { Devise.friendly_token[0, 20] }
    end
  end
end

FactoryBot.define do
  factory :habit_log do
    association :user
    association :habit
    log_date { Date.current }
    is_taken { false }
  end
end

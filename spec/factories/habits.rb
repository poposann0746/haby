FactoryBot.define do
  factory :habit do
    association :user
    name { "毎日の習慣" }
    detail { "テスト用の習慣です" }
    current_streak { 0 }
    longest_streak { 0 }
    schedule_days { [] }

    trait :weekday do
      name { "平日の習慣" }
      schedule_days { [ 1, 2, 3, 4, 5 ] }
    end

    trait :weekend do
      name { "週末の習慣" }
      schedule_days { [ 0, 6 ] }
    end

    trait :monday_only do
      name { "月曜日の習慣" }
      schedule_days { [ 1 ] }
    end
  end
end

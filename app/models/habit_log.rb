class HabitLog < ApplicationRecord
  belongs_to :user
  belongs_to :habit
  #belongs_to :habit_schedule

  validates :log_date, presence: true
  validates :is_taken, inclusion: { in: [true, false]}

  validates :habit_id, uniqueness: { scope: {:user_id, :log_date} }
end

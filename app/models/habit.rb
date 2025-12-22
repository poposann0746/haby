class Habit < ApplicationRecord
  belongs_to :user
  # belongs_to :category_id, optional: true

  # has_many :habit_schedules, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :current_streak, :longest_streak, numericality: { greater_than_or_equal_to: 0 }

  scope :active_on, ->(date) {
    where("created_at <= ?", date.end_of_day)
  }
end

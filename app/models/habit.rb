class Habit < ApplicationRecord
  belongs_to :user
  # belongs_to :category_id, optional: true

  # has_many :habit_schedules, dependent: :destroy
  has_many :habit_logs, dependent: :destroy

  # 曜日定数
  WEEKDAYS = (1..5).to_a.freeze  # 月〜金
  WEEKENDS = [ 0, 6 ].freeze      # 日、土
  ALL_DAYS = (0..6).to_a.freeze   # 全曜日

  # 曜日名のマッピング（表示用）
  DAY_NAMES = {
    0 => "日", 1 => "月", 2 => "火", 3 => "水",
    4 => "木", 5 => "金", 6 => "土"
  }.freeze

  validates :name, presence: true, length: { maximum: 100 }
  validates :current_streak, :longest_streak, numericality: { greater_than_or_equal_to: 0 }

  scope :active_on, ->(date) {
    where("created_at <= ?", date.end_of_day)
  }

  # 指定日に実施すべき習慣を取得
  scope :scheduled_for, ->(date) {
    wday = date.wday
    where("schedule_days = '{}' OR ? = ANY(schedule_days)", wday)
  }

  # 曜日が設定されているか
  def schedule_days_set?
    schedule_days.present?
  end

  # 指定日に実施すべきか
  def scheduled_on?(date)
    return true if schedule_days.blank?
    schedule_days.include?(date.wday)
  end

  # 曜日表示用の文字列を返す
  def schedule_days_display
    return "毎日" if schedule_days.blank?
    return "毎日" if schedule_days.sort == ALL_DAYS.sort

    schedule_days.sort_by { |d| (d - 1) % 7 }.map { |d| DAY_NAMES[d] }.join("・")
  end
end

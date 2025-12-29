class HabitLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: %i[update]
  before_action :set_date, only: %i[index]

  def index
    @rows = []

    @date =
      if params[:date].present?
        Date.parse(params[:date])
      else
        Date.current
      end

    habits =
      current_user.habits
        .where("created_at <= ?", @date.end_of_day)
        .order(created_at: :asc)

    day_logs =
      current_user.habit_logs
        .includes(:habit)
        .where(log_date: @date.beginning_of_day..@date.end_of_day)

    logs_by_habit_id = day_logs.index_by(&:habit_id)

    @rows = habits.map do |habit|
      log = logs_by_habit_id[habit.id]
      {
        habit: habit,
        log: log,
        is_taken: log&.is_taken || false
      }
    end
  end

  def update
    @habit = current_user.habits.find(params[:habit_id])
    log = @habit.habit_logs.find_or_initialize_by(log_date: Date.current)
    log.user = current_user
    log.is_taken = !log.is_taken?
    log.save!

    redirect_back fallback_location: habits_path,
                  notice: log.is_taken? ? "実施にチェックしました" : "実施チェックを外しました"
  rescue ActiveRecord::RecordInvalid
    redirect_back fallback_location: habits_path, alert: "保存に失敗しました"
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:habit_id])
  end

  def set_date
    @date =
      if params[:date].present?
        Date.parse(params[:date])
      else
        Date.current
      end
  rescue ArgumentError
    @date = Date.current
  end
end

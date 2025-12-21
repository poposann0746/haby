class HabitLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: %i[update]
  before_action :set_date, only: %i[index]

  def index
    # その日のログ一覧
    @habit_logs = current_user.habit_logs
                             .where(log_date: @date)
                             .includes(:habit)
                             .order("habits.name ASC")
  end

  def update
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

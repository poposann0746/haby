class HabitLogsController < ApplicationController
  before_action :authenticate_user!

  def index
    @date =params[:date]&.to_date || Date.current

    @habit_logs = HabitLog
      .includes(:habit)
      .where(user: current_user, log_date: @date)
      .joins(:habit)
      .order("habits.created_at ASC")
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


end

class HabitsController < ApplicationController
  require "ostruct"
  before_action :authenticate_user!
  before_action :set_habit, only: %i[show edit update destroy]

  def index
    @habits = current_user.habits.order(created_at: :asc)

    # もし habits/index で「今日の実施/未実施」も表示するなら（エラー文に出てるので）
    today_logs =
      current_user.habit_logs
        .where(log_date: Date.current.beginning_of_day..Date.current.end_of_day)

    @today_logs_by_habit_id = today_logs.index_by(&:habit_id)
  end
  
  def new
    @habit = current_user.habits.build
  end

  def create
    @habit = current_user.habits.build(habit_params)

    if @habit.save
      redirect_to habits_path, notice: "習慣を追加しました"
    else
      prepare_index
      render :index, status: :unprocessable_entity
    end
  end

  def show
    @habit = current_user.habits.find(params[:id])
  end

  def edit
  end

  def update
    if @habit.update(habit_params)
      redirect_to habits_path(@habit), notice: "習慣を更新しました"
    else
      flash.now[:alert] = "更新に失敗しました"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @habit.destroy
    redirect_to habits_path, notice: "習慣を削除しました"
  end

  private

  def set_habit
    @habit = current_user.habits.find(params[:id])
  end

  def habit_params
    params.require(:habit).permit(:name, :detail)
  end

  def prepare_index
    @habits = current_user.habits.order(created_at: :desc)

    today = Date.current
    logs = HabitLog.where(user_id: current_user.id, log_date: today, habit_id: @habits.pluck(:id))
    @today_logs_by_habit_id = logs.index_by(&:habit_id)
  end
end

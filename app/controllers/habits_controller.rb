class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: %i[show edit update destroy]

  def index
    @habits = current_user.habits.order(created_at: :desc)
    today_logs = HabitLog
    .where(user_id: current_user.id, habit_id: @habits.ids, log_date: Date.current)
    .index_by(&:habit_id)

    @today_logs_by_habit_id = today_logs
  end

  def new
    @habit = current_user.habits.build
  end

  def create
    @habit = current_user.habits.build(habit_params)

    if @habit.save
      redirect_to habits_path, notice: "習慣を登録しました！"
    else
      @habits = current_user.habits.order(created_at: :desc)
      flash.now[:alert] = "入力内容を確認してください"
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
end

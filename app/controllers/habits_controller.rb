class HabitsController < ApplicationController
  before_action :authenticate_user!

  def index
    @habits = current_user.habits.order(created_at: :desc)
    @habit  = current_user.habits.build
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

  private

  def habit_params
    params.require(:habit).permit(:name, :detail)
  end
end

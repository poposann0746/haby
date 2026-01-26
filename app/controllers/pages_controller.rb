class PagesController < ApplicationController
  before_action :authenticate_user!, only: [
    :calendar, :habits, :manage, :todays_habits,
    :account,
    :edit_name, :update_name,
    :edit_email, :update_email,
    :edit_password, :update_password,
    :confirm_delete_account, :destroy_account
  ]

  def calendar
    base_date = params[:start_date].present? ? Date.parse(params[:start_date]) : Date.current
    from = base_date.beginning_of_month
    to   = base_date.end_of_month

    # その月のログを一括取得
    logs_in_month = current_user.habit_logs
      .where(log_date: from..to)
      .where(is_taken: true)
      .pluck(:habit_id, :log_date)
      .group_by { |_, date| date }
      .transform_values { |records| records.map(&:first).uniq }
    # => { Date => [habit_id, habit_id, ...], ... }

    # 全習慣を取得（曜日設定と作成日を含む）
    all_habits = current_user.habits.select(:id, :schedule_days, :created_at).to_a

    @day_class = {}

    (from..to).each do |date|
      # その日に実施すべき習慣を計算（曜日設定 + 作成日を考慮）
      scheduled_habits = all_habits.select do |habit|
        habit.created_at <= date.end_of_day && habit.scheduled_on?(date)
      end

      total = scheduled_habits.size
      completed_habit_ids = logs_in_month[date] || []
      taken = scheduled_habits.count { |h| completed_habit_ids.include?(h.id) }

      @day_class[date] =
        if total == 0
          "cal-day--none"
        elsif taken == 0
          "cal-day--none"
        elsif taken < total
          "cal-day--partial"
        else
          "cal-day--all"
        end
    end
  end






  def manage; end

  # 今日の習慣
  def todays_habits
    today = Date.current

    # 今日実施すべき習慣を取得
    habits = current_user.habits
      .scheduled_for(today)
      .active_on(today)
      .order(created_at: :asc)

    # 今日のログを一括取得（N+1対策）
    today_logs = current_user.habit_logs
      .where(habit: habits, log_date: today)
      .index_by(&:habit_id)

    # 完了/未完了に分類
    @incomplete_habits = []
    @completed_habits = []

    habits.each do |habit|
      log = today_logs[habit.id]
      if log&.is_taken?
        @completed_habits << { habit: habit, log: log }
      else
        @incomplete_habits << { habit: habit, log: log }
      end
    end

    @today = today
  end

  # マイページ
  def account
  end

  # 名前変更
  def edit_name
  end

  def update_name
    if current_user.update(name_params)
      redirect_to account_path, notice: "名前を変更しました。"
    else
      render :edit_name, status: :unprocessable_entity
    end
  end

  # メールアドレス変更（現在のパスワードを要求）
  def edit_email
  end

  def update_email
    # Devise の update_with_password を利用（current_password が必要）
    if current_user.update_with_password(email_params)
      # メールやパスワードを変えたら再ログイン状態を維持
      bypass_sign_in(current_user)
      redirect_to account_path, notice: "メールアドレスを変更しました。"
    else
      render :edit_email, status: :unprocessable_entity
    end
  end

  # パスワード変更
  def edit_password
  end

  def update_password
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to account_path, notice: "パスワードを変更しました。"
    else
      render :edit_password, status: :unprocessable_entity
    end
  end

  # アカウント削除確認
  def confirm_delete_account
  end

  # 本当に削除
  def destroy_account
    user = current_user
    sign_out user
    user.destroy!
    redirect_to root_path, notice: "アカウントを削除しました。ご利用ありがとうございました。"
  end

  private

  def name_params
    params.require(:user).permit(:name)
  end

  def email_params
    # email + current_password だけを受け取る
    params.require(:user).permit(:email, :current_password)
  end

  def password_params
    # current_password + 新しいパスワード + 確認
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end
end

class PagesController < ApplicationController
  before_action :authenticate_user!, only: [
    :calendar, :habits, :manage,
    :account,
    :edit_name, :update_name,
    :edit_email, :update_email,
    :edit_password, :update_password,
    :confirm_delete_account, :destroy_account
  ]

  def calendar
    base_date =
      if params[:start_date].present?
        Date.parse(params[:start_date])
      else
        Date.current
      end

    from = base_date.beginning_of_month
    to   = base_date.end_of_month

    logs = current_user.habit_logs.where(log_date: from..to)

    logs_by_date = logs.group_by(&:log_date)

    @day_class = {}
    logs_by_date.each do |date, day_logs|
      total = day_logs.size
      taken = day_logs.count { |l| l.is_taken }

      @day_class[date] =
        if taken == total
          "cal-day--all"
        elsif taken == 0
          "cal-day--none"
        else
          "cal-day--partial"
        end
    end
  end



  def manage; end

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

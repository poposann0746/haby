class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_omniauth("Google")
  end

  def failure
    redirect_to new_user_session_path, alert: "認証に失敗しました。もう一度お試しください。"
  end

  private

  def handle_omniauth(provider_name)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      flash[:notice] = "#{provider_name}アカウントでログインしました。"
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:alert] = "#{provider_name}アカウントでの認証に失敗しました。"
      redirect_to new_user_session_path
    end
  rescue StandardError => e
    Rails.logger.error "OmniAuth error (#{provider_name}): #{e.message}"
    flash[:alert] = "認証処理中にエラーが発生しました。もう一度お試しください。"
    redirect_to new_user_session_path
  end
end

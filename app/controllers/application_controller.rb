class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Deviseコントローラのときだけ、追加パラメータを許可する
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Deviseにnameパラメータを許可する
  def configure_permitted_parameters
    # 新規登録時
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    # アカウント編集時
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :email ])
  end

  def after_sign_in_path_for(resource)
    habits_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end

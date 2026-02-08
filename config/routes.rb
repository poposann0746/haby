Rails.application.routes.draw do
  get "contacts/new"
  devise_for :users
  resources :habits, only: %i[new create index show edit update destroy]
  resources :habits do
    resource :today_log, only: [ :update ], controller: "habit_logs"
  end
  resources :habit_logs, only: %i[index]

  root "home#index"
  get "home/index"

  get "privacy",  to: "static_pages#privacy"
  get "terms",    to: "static_pages#terms"
  get "contact", to: "contacts#new"
  post "contact", to: "contacts#create"

  get "calendar", to: "pages#calendar"
  get "manage", to: "pages#manage"
  get "todays_habits", to: "pages#todays_habits"

  # マイページ
  get "account", to: "pages#account", as: :account

  # 名前変更
  get   "account/name/edit", to: "pages#edit_name",   as: :edit_account_name
  patch "account/name",      to: "pages#update_name", as: :account_name

  # メールアドレス変更
  get   "account/email/edit", to: "pages#edit_email",   as: :edit_account_email
  patch "account/email",      to: "pages#update_email", as: :account_email

  # パスワード変更
  get   "account/password/edit", to: "pages#edit_password",   as: :edit_account_password
  patch "account/password",      to: "pages#update_password", as: :account_password

  # アカウント削除
  get    "account/delete", to: "pages#confirm_delete_account", as: :confirm_delete_account
  delete "account",        to: "pages#destroy_account",        as: :destroy_account

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

end

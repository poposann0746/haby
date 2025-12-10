Rails.application.routes.draw do
  get "pages/calendar"
  get "pages/habits"
  get "pages/account"
  get "pages/manage"
  get "pages/calendar"
  get "pages/todays_habits"
  get "pages/accout"
  get "pages/manage"
  devise_for :users
  root "home#index"
  get "home/index"

  get "privacy",  to: "static_pages#privacy"
  get "terms",    to: "static_pages#terms"
  get "contact",  to: "static_pages#contact"

  get "calendar", to: "pages#calendar"
  get "habits", to: "pages#habits"
  get "manage", to: "pages#manage"
  get "account", to: "pages#account"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"

  namespace :demo do
    resource  :session,       only: [:create]
    resources :notifications, only: [:index, :update]
    resources :channels,      only: [:index] do
      resources :messages, only: [:index, :create], shallow: true
    end
  end if Rails.application.config.demo_mode
end

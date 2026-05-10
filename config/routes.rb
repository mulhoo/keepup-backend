Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"

  namespace :demo do
    resource  :session,       only: [:create]
    resources :notifications, only: [:index, :update]
    resources :activities, only: [:index] do
      member do
        post :notify_parents
        post :notify_ad
        post :notify_district_admin
      end
    end
    resources :channels,      only: [:index] do
      resources :messages, only: [:index, :create], shallow: true do
        post :translate, on: :member
      end
    end
  end if Rails.application.config.demo_mode
end

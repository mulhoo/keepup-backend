Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"

  post "uploads/presign", to: "uploads#presign"

  namespace :auth do
    resource :session, only: [ :show ]
  end

  namespace :admin do
    resources :staff, only: [ :index, :create, :update, :destroy ] do
      member do
        patch :restore
        patch :assign_sport
      end
    end
    resource  :district, only: [ :show, :update ]
    resources :seasons,  only: [ :index ]
    resources :sports,   only: [ :index, :show ] do
      member do
        patch  :set_commissioner
        delete :remove_commissioner
        patch  :update_levels
      end
      resources :members, only: [ :update ], param: :user_id, controller: "season_members"
    end
    resources :students, only: [ :destroy ]
  end

  resources :invitations, only: [ :show ], param: :token do
    post :accept, on: :member
  end

  namespace :demo do
    post "reset", to: "resets#create"
    scope "/safety" do
      post "request_code", to: "safety#request_code"
      post "verify",       to: "safety#verify"
      post "end_session",       to: "safety#end_session"
      post "chats/search",      to: "safety#chats"
      get  "audit_events",      to: "safety#audit_events"
      post "flag_conversation", to: "safety#flag_conversation"
    end
    resource  :session,       only: [ :create, :destroy ]
    resource  :me,            only: [ :show ], controller: :users do
      patch :accessibility,  on: :member
      patch :preferences,    on: :member
    end
    resources :notifications, only: [ :index, :update ] do
      collection { patch :mark_all_read }
    end
    resources :announcements,           only: [ :index, :create ]
    resources :safety_review_signals,   only: [ :index, :create ]
    resources :flagged_messages,        only: [ :index ] do
      member { patch :review }
    end
    resources :family_groups,           only: [ :index, :create ] do
      member { post :add_members }
    end
    resources :activities, only: [ :index ] do
      member do
        post :notify_parents
        post :notify_ad
        post :notify_district_admin
        post :delete_message
      end
    end
    post "moderate",        to: "moderate#create"
    get  "themes",          to: "themes#index"
    post "themes/generate", to: "themes#generate"
    resources :seasons,          only: [ :index ]
    resources :dm_conversations, only: [ :index, :create ] do
      collection do
        get :startable
      end
      member do
        get  :messages
        post :send_message
        post :mark_read
        post "messages/:message_id/report", action: :report_dm_message
      end
    end
    get "users/:id", to: "users#profile"
    resources :channels,      only: [ :index ] do
      post   :mark_read, on: :member
      delete :leave,     on: :member
      resources :members,  only: [ :index, :create ], controller: "channel_members"
      resources :messages, only: [ :index, :create ], shallow: true do
        post :translate, on: :member
        post :report,    on: :member
        post :remove,    on: :member
        post   "reactions/toggle", to: "reactions#toggle"
        get    :thread,            to: "threads#show"
        post   :thread,            to: "threads#create"
      end
    end
    resources :schools,              only: [ :index, :show ]
    resources :results, only: [ :index, :create ] do
      collection do
        get  :team
        post :generate_summary
        post :parse_pdf
      end
      member do
        patch :confirm
        patch :approve
      end
    end
    resources :qualification_flags, only: [ :index ] do
      member { patch :accept }
    end
    resources :time_standards, only: [ :index ] do
      collection { post :bulk_update }
    end
    get  "linked-accounts",         to: "linked_accounts#index"
    get  "linked-accounts/pending", to: "linked_accounts#pending"
    get  "family",                  to: "family#index"
    get  "family/chats",            to: "family#chats"
    post "coach-conversations/:id/alert_ad", to: "coach_conversations#alert_ad"
    post "message-challenges",                    to: "message_challenges#create"
    patch "message-challenges/:id/uphold",        to: "message_challenges#uphold"
    patch "message-challenges/:id/deny",          to: "message_challenges#deny"
    post "parent-view-requests",                  to: "parent_view_requests#create"
    get  "parent-view-requests",                  to: "parent_view_requests#index"
    patch "parent-view-requests/:id/approve",     to: "parent_view_requests#approve"
    patch "parent-view-requests/:id/deny",        to: "parent_view_requests#deny"
  end if Rails.application.config.demo_mode
end

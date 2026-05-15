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
      resources :calendar_events, only: [ :index, :create, :update, :destroy ]
      resources :members, only: [ :update ], param: :user_id, controller: "season_members"
    end
    resources :calendar_events, only: [] do
      member do
        patch :annotate, to: "event_annotations#annotate"
      end
    end
    resources :students, only: [ :destroy ]
    get  "schedule", to: "schedule#index"
    post "import",   to: "imports#create"
  end

  resources :invitations, only: [ :show ], param: :token do
    post :accept, on: :member
  end

  namespace :demo do
    scope "/safety" do
      post "request_code", to: "safety#request_code"
      post "verify",       to: "safety#verify"
      post "end_session",       to: "safety#end_session"
      get  "chats",             to: "safety#chats"
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
    resources :family_groups,           only: [ :index, :create ]
    resources :activities, only: [ :index ] do
      member do
        post :notify_parents
        post :notify_ad
        post :notify_district_admin
      end
    end
    resources :channels,      only: [ :index ] do
      resources :messages, only: [ :index, :create ], shallow: true do
        post :translate, on: :member
      end
    end
    resources :schools,              only: [ :index, :show ]
    resources :commissioner_events,  only: [ :index, :update ] do
      member { post :notify }
    end
    resources :venues, only: [ :index, :create, :update, :destroy ] do
      member { patch :set_closed }
    end
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
    post "message-challenges",                    to: "message_challenges#create"
    patch "message-challenges/:id/uphold",        to: "message_challenges#uphold"
    patch "message-challenges/:id/deny",          to: "message_challenges#deny"
    post "parent-view-requests",                  to: "parent_view_requests#create"
    get  "parent-view-requests",                  to: "parent_view_requests#index"
    patch "parent-view-requests/:id/approve",     to: "parent_view_requests#approve"
    patch "parent-view-requests/:id/deny",        to: "parent_view_requests#deny"
  end if Rails.application.config.demo_mode
end

# frozen_string_literal: true

require 'sidekiq/web'

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    # Protect against timing attacks:
    # - See https://codahale.com/a-lesson-in-timing-attacks/
    # - See https://web.archive.org/web/20180709235757/https://thisdata.com/blog/timing-attacks-against-string-comparison/
    # - Use & (do not use &&) so that it doesn't short circuit.
    ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(username),
                                                Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_WEB_UI_USERNAME', nil))) &
      ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(password),
                                                  Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_WEB_UI_PASSWORD', nil)))
  end
  mount Sidekiq::Web => '/sidekiq'

  root 'home#index'

  get :ping, to: 'healthcheck#ping'

  devise_for(
    :users,
    controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks'
    }
  )

  get 'users/auth/failure', to: 'errors#forbidden'

  devise_scope :user do
    if FeatureFlags.dev_auth.enabled?
      get 'dev_auth', to: 'users/dev_auth#new', as: :new_user_session
    else
      get 'unauthorized', to: 'errors#forbidden', as: :new_user_session
    end

    authenticated :user do
      get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
    end
  end

  resources :healthcheck, only: [] do
    collection do
      get :ping
    end
  end

  namespace :nsm do
    root to: 'claims#your'
    resources :claims, only: [:create] do
      collection do
        get :your
        get :open
        get :closed
      end

      resources :adjustments, only: [] do
        collection { get :confirm_deletion }
        collection { put :delete_all }
      end

      resource :claim_details, only: [:show]
      namespace :letters_and_calls do
        resource :uplift, only: [:edit, :update], path_names: { edit: '' }
      end
      namespace :work_items do
        resource :uplift, only: [:edit, :update], path_names: { edit: '' }
      end
      resources :work_items, only: [:index, :show, :edit, :update, :destroy] do
        collection { get :adjusted }
        member { get :confirm_deletion }
      end
      resources :letters_and_calls, only: [:index, :show, :edit, :update, :destroy], constraints: { id: /(letters|calls)/ } do
        collection { get :adjusted }
        member { get :confirm_deletion }
      end
      resources :disbursements, only: [:index, :show, :edit, :update, :destroy] do
        collection { get :adjusted }
        member { get :confirm_deletion }
      end
      constraints ->(_req) { FeatureFlags.youth_court_fee.enabled? } do
        resources :additional_fees, only: [:index, :show, :edit, :update, :destroy] do
          collection { get :adjusted }
          member { get :confirm_deletion }
        end
      end
      resource :supporting_evidences, only: [:show] do
        resources :downloads, only: :show
      end
      resource :history, only: [:show, :create]
      resource :change_risk, only: [:edit, :update], path_names: { edit: '' }
      resource :make_decision, only: [:edit, :update], path_names: { edit: '' }
      resource :send_back, only: [:edit, :update, :show]
      resource :unassignment, only: [:edit, :update], path_names: { edit: '' }
      resources :assignments, only: %i[new create]
    end

    resources :further_information_downloads, only: :show
    resource :search, only: %i[new show]
    get 'claims/:claim', to: redirect('claims/%{claim}/claim_details')
  end

  namespace :about do
    resources :feedback, only: [:index, :create]
    resources :cookies, only: [:index, :create]
    get :update_cookies, to: 'cookies#update_cookies'
    resources :privacy, only: [:index]
    resources :accessibility, only: [:index]
  end

  namespace :prior_authority do
    root to: 'applications#your'
    resources :applications, only: [:new, :show] do
      collection do
        get :your
        get :open
        get :closed
      end

      resources :adjustments, only: :index
      resources :related_applications, only: :index
      resources :service_costs, only: %i[edit update destroy] do
        member { get :confirm_deletion }
      end
      resources :travel_costs, only: %i[edit update destroy] do
        member { get :confirm_deletion }
      end
      resources :additional_costs, only: %i[edit update destroy] do
        member { get :confirm_deletion }
      end
      resources :manual_assignments, only: %i[new create]
      resources :unassignments, only: %i[new create]
      resource :decision, only: %i[new create show]
      resources :events, path: :history, only: :index
      resource :send_back, only: %i[new create show]
      resources :notes, only: %i[new create]
    end
    resources :auto_assignments, only: [:create]
    resources :downloads, only: :show
    resource :search, only: %i[new show]
  end

  constraints ->(_req) { FeatureFlags.payments.enabled? } do
    namespace :payments do
      resources :requests
      resource :search, only: %i[new show]
    end
  end

  get 'robots.txt', to: 'robots#index'

  resource :dashboard, only: %i[new show]
  resources :users
end
# rubocop:enable Metrics/BlockLength

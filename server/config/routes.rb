Rails.application.routes.draw do
  # Routes for your own Spree API v3 resources. `bin/rails g spree:api_resource`
  # adds a line here for each resource it generates; you can also add your own.
  Spree::Core::Engine.add_routes do
    namespace :api, defaults: { format: 'json' } do
      namespace :v3 do
        namespace :store do
        end
        namespace :admin do
          namespace :pos do
            get 'configuration/staff', to: 'configuration_options#staff'
            get 'configuration/locations', to: 'configuration_options#locations'
            get 'catalog', to: 'catalog#index'
            get 'units', to: 'units#index'
            get 'units/variant', to: 'units#variant_units'
            put 'units/variant', to: 'units#update_variant_unit'
            post 'measurement_barcodes/parse', to: 'measurement_barcodes#parse'
            get 'traceability', to: 'traceability#show'
            resources :customers, only: [:index, :create]
            resources :received_funds, only: [:index, :show, :create] do
              member do
                post 'payouts', to: 'received_funds#request_payout'
                post 'payouts/:payout_id/confirm', to: 'received_funds#confirm_payout'
                post 'payouts/:payout_id/resolve', to: 'received_funds#resolve_payout'
              end
            end
            resources :branches, only: [] do
              resources :branch_products, only: [:index, :create, :destroy], path: 'products'
              resources :label_formats, only: [:index, :create, :update] do
                member do
                  post :disable
                end
              end
            end
            resource :context, only: [:show], controller: 'context'
            get 'context/branches', to: 'context_branches#index'
            get 'context/registers', to: 'context_registers#index'
            get 'command_receipts', to: 'command_receipts#index'
            resources :branches, only: [:index, :show, :create, :update] do
              member do
                post :disable
                post :enable
              end
            end
            resources :registers, only: [:index, :show, :create, :update] do
              member do
                post :disable
                post :enable
              end
            end
            resources :memberships, only: [:index, :show, :create, :update] do
              member do
                post :disable
                post :enable
              end
            end
            resources :shifts, only: [:index, :show, :create]
            resources :approvals, only: [:index, :show, :create] do
              member do
                post :revoke
              end
            end
            resources :workspaces, only: [:index, :show, :create] do
              post 'items/:id/update', to: 'workspaces/items#update'
              post 'items/:id/remove', to: 'workspaces/items#destroy'
              post 'customer', to: 'workspaces/customers#update'
              post 'customer/clear', to: 'workspaces/customers#destroy'
              post 'note', to: 'workspaces/notes#update'
              resources :items, only: [:create], controller: 'workspaces/items'
              post 'items/:id/line_discount', to: 'workspaces/line_discounts#create'
              delete 'items/:id/line_discount', to: 'workspaces/line_discounts#destroy'
              post 'items/:id/price_override', to: 'workspaces/price_overrides#create'
              resource :discount, only: [:create], controller: 'workspaces/discounts'
              post 'coupon', to: 'workspaces/discounts#coupon'
              post 'coupon/clear', to: 'workspaces/discounts#clear_coupon'
              get 'payment_methods', to: 'workspaces/payment_methods#index'
              resources :tender_attempts, only: [:index, :create], controller: 'workspaces/tender_attempts' do
                member do
                  post :confirm, to: 'workspaces/tender_attempts#confirm'
                  post :cancel, to: 'workspaces/tender_attempts#cancel'
                end
              end
              post 'funds/allocate', to: 'workspaces/funds#allocate'
              post 'funds/reverse', to: 'workspaces/funds#reverse'
              post 'complete', to: 'workspaces/completions#create'
              member do
                post 'discount/clear', to: 'workspaces/discounts#clear'
                post :park
                post :reopen
                post :cancel
                post :lease, to: 'workspaces/leases#create'
                patch :lease, to: 'workspaces/leases#update'
                post :handover, to: 'workspaces/handovers#create'
              end
            end
          end
        end
      end
    end
  end

  # The app's front door is the dashboard. Spree resolves where it lives:
  # SPREE_DASHBOARD_URL when set, else the /dashboard this app serves, else
  # the Vite dev server in development. 302, not 301, so browsers don't cache
  # it past a change of SPREE_DASHBOARD_URL.
  root to: redirect(status: 302) { Spree::Stores::DashboardUrl.call.presence || '/dashboard' }

  # This line mounts Spree's routes at the root of your application.
  # This means, any requests to URLs such as /products, will go to
  # Spree::ProductsController.
  # If you would like to change where this engine is mounted, simply change the
  # :at option to something different.
  #
  # We ask that you don't use the :as option here, as Spree relies on it being
  # the default of "spree".
  mount Spree::Core::Engine, at: '/'

  # Job dashboard (Mission Control) — inspect, retry, and discard Solid Queue
  # jobs at http://localhost:3000/jobs. Guarded by its own HTTP Basic auth
  # (see config/application.rb), independent of app sessions.
  mount MissionControl::Jobs::Engine, at: "/jobs"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end

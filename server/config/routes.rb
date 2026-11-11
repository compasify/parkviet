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
            post 'units', to: 'units#create'
            constraints(id: /posunit_[^\/]+/) do
              match 'units/:id', to: 'units#update', via: %i[patch put]
              post 'units/:id/disable', to: 'units#disable'
              post 'units/:id/enable', to: 'units#enable'
            end
            resources :payment_methods, only: [:index, :create, :update, :destroy]
            resources :staff_roles, only: [:index, :show, :create, :update, :destroy]
            resources :label_formats, only: [:index, :create, :update] do
              member do
                post :disable
              end
            end
            post 'measurement_barcodes/parse', to: 'measurement_barcodes#parse'
            get 'traceability', to: 'traceability#show'
            namespace :inventory do
              get 'variants', to: 'traceability#variants'
              post 'opening_balances', to: 'traceability#opening_balance'
              post 'receipts', to: 'traceability#receipt'
              post 'transfers', to: 'traceability#transfer'
              get 'adjustments', to: 'traceability#adjustments'
              post 'adjustments', to: 'traceability#create_adjustment'
              post 'adjustments/:id/approve', to: 'traceability#approve_adjustment'
              post 'adjustments/:id/apply', to: 'traceability#apply_adjustment'
              post 'adjustments/:id/cancel', to: 'traceability#cancel_adjustment'
              get 'recall', to: 'traceability#recall'
            end
            resources :lots, only: [:index] do
              member do
                post :quarantine
                post :release
              end
            end
            resources :serial_units, only: [:index] do
              member do
                post :quarantine
                post :release
              end
            end
            resources :customers, only: [:index, :create]
            post 'customers/:id/update', to: 'customers#amend'
            resources :received_funds, only: [:index, :show, :create] do
              member do
                post 'payouts', to: 'received_funds#request_payout'
                post 'payouts/:payout_id/confirm', to: 'received_funds#confirm_payout'
                post 'payouts/:payout_id/resolve', to: 'received_funds#resolve_payout'
              end
            end
            resources :credit_accounts, only: [:index, :create, :update]
            resources :credit_requests, only: [:index] do
              member do
                post :approve
                post :reject
                post :revoke
              end
            end
            get 'orders/lookup', to: 'orders#lookup'
            resources :orders, only: [:index, :show] do
              member do
                post :reconcile_handover
              end
            end
            post 'returns/preview', to: 'returns#preview'
            resources :returns, only: [:index, :show, :create] do
              member do
                post :approve
                post :receive
                post :cancel
              end
            end
            resources :refund_requests, only: [:index, :show, :create] do
              member do
                post :approve
              end
              resource :confirmation, only: [:create], controller: 'refund_requests/confirmations'
              resource :resolution, only: [:create], controller: 'refund_requests/resolutions'
            end
            resources :exchanges, only: [:show, :create]
            get 'receivables', to: 'receivables#index'
            get 'receivables/customers', to: 'receivables#customers'
            post 'receivables/customers/:id/remind', to: 'receivables#remind'
            resources :collections, only: [:show, :create] do
              resources :allocations, only: [:create], controller: 'collections/allocations' do
                member do
                  post :reverse
                end
              end
            end
            resources :branches, only: [] do
              resources :branch_products, only: [:index, :create, :destroy], path: 'products'
              resources :label_formats, only: [:index, :create, :update] do
                member do
                  post :disable
                end
              end
              put 'label_formats', to: 'label_formats#assign'
              get 'payment_methods', to: 'branch_payment_methods#show'
              put 'payment_methods', to: 'branch_payment_methods#update'
              get 'receipt_templates', to: 'branch_receipt_templates#show'
              put 'receipt_templates', to: 'branch_receipt_templates#update'
            end
            resources :receipt_templates, only: [:index, :show, :create, :update] do
              member do
                get :versions
                post :duplicate
                post :default
                post :restore
                post :disable
              end
            end
            resource :context, only: [:show], controller: 'context'
            get 'context/branches', to: 'context_branches#index'
            get 'context/registers', to: 'context_registers#index'
            get 'command_receipts', to: 'command_receipts#index'
            resources :feature_flags, only: [:index, :update]
            get 'business_profiles', to: 'business_profiles#show'
            resource :store_profile, only: [:show, :update]
            post 'onboarding', to: 'onboarding#create'
            get 'operations/metrics', to: 'operational_metrics#show'
            get 'system_status', to: 'system_status#show'
            resources :branches, only: [:index, :show, :create, :update] do
              member do
                post :disable
                post :enable
                post 'profile/preview', action: :profile_preview
                put :profile
              end
              # Module keys contain a dot (retail.units), so the id takes any segment.
              resources :modules, only: [:index, :update], controller: 'branch_modules', constraints: { id: %r{[^/]+} }
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
            # Shift close, drawer cash, late-cash reconciliation, reports and exports.
            resources :shifts, only: [] do
              member do
                get 'closure', to: 'shifts/closures#show'
                post 'count', to: 'shifts/closures#count'
                post 'close', to: 'shifts/closures#create'
                post 'close_approval', to: 'shifts/closures#approve'
                get 'cash_movements', to: 'shifts/cash_movements#index'
                post 'cash_movements', to: 'shifts/cash_movements#create'
              end
            end
            get 'shift_closures/pending', to: 'shifts/closures#pending'
            get 'shift_closures/open', to: 'shifts/closures#open'
            get 'cash_reconciliations/candidates', to: 'cash_reconciliations#candidates'
            resources :cash_reconciliations, only: [:index, :create]
            get 'reports/:report', to: 'reports#show', as: :report, constraints: { report: /sales|receipts|cashbook|receivables|closures|ingredient_usage|menu_margin/ }
            resources :exports, only: [:index, :show, :create] do
              member do
                post :download_link
              end
            end
            get 'export_files/:token', to: 'export_files#show', as: :export_file, format: false
            resources :cash_movement_requests, only: [:index], controller: 'shifts/cash_movement_requests' do
              member do
                post :confirm
                post :cancel
              end
            end
            # Receipts and the customer display (cashier side).
            get 'receipts/lookup', to: 'receipts#lookup'
            resources :receipts, only: [:index, :show] do
              member do
                post :prints
                post 'prints/:print_id/void', action: :void_print
              end
            end
            # The store's menu, and a branch's sold-out items and favourites.
            get 'menu', to: 'menu#show'
            resources :menu_categories, only: [:index, :create, :update, :destroy]
            resources :menu_items, only: [:index, :create, :update, :destroy]
            resources :modifier_groups, only: [:index, :create, :update, :destroy]
            resources :menu_schedules, only: [:index, :create, :update, :destroy]
            put 'menu_availabilities', to: 'menu_availabilities#update'
            put 'menu_favorites', to: 'menu_favorites#update'
            # Recipes of menu sizes and options, and a branch's low-stock thresholds.
            get 'recipes', to: 'recipes#show'
            put 'recipes', to: 'recipes#update'
            get 'stock_alerts', to: 'stock_alerts#index'
            put 'stock_alerts', to: 'stock_alerts#update'
            # E-invoices of completed orders and the store's provider settings.
            get 'einvoices/summary', to: 'einvoices#summary'
            post 'einvoices/retry', to: 'einvoices#retry_issue'
            resources :einvoices, only: [:index, :show] do
              member do
                put :buyer, action: :update_buyer
                post :cancel
                post :replace
              end
            end
            get 'einvoice_settings', to: 'einvoice_settings#show'
            put 'einvoice_settings', to: 'einvoice_settings#update'
            post 'einvoice_settings/test', to: 'einvoice_settings#sample'
            resources :printers, only: [:index, :create, :update, :destroy] do
              collection do
                get :stations
              end
              member do
                post :test
              end
            end
            resources :print_jobs, only: [:index, :create] do
              get :prebills, on: :collection
              member do
                post :reprint
                post :cancel
              end
            end
            get 'display_sessions/current', to: 'display_sessions#current'
            resources :display_sessions, only: [:show, :create] do
              member do
                post :pin
                post :clear
                post :revoke
                post :pairing_code
              end
            end
            # Delivery orders of a branch ("Đơn cần giao").
            get 'deliveries/deliverers', to: 'deliveries#deliverers'
            resources :deliveries, only: [:index] do
              member do
                post :deliver
                post :reopen
              end
            end
            resources :devices, only: [:index, :update] do
              collection do
                post :pairing, to: 'devices#create_pairing'
              end
              member do
                post :revoke
              end
            end
            get 'staff_pins', to: 'staff_pins#index'
            put 'staff_pins', to: 'staff_pins#update'
            delete 'staff_pins', to: 'staff_pins#destroy'
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
              patch 'items/:id/modifiers', to: 'workspaces/item_modifiers#update'
              resource :discount, only: [:create], controller: 'workspaces/discounts'
              post 'coupon', to: 'workspaces/discounts#coupon'
              post 'coupon/clear', to: 'workspaces/discounts#clear_coupon'
              get 'payment_methods', to: 'workspaces/payment_methods#index'
              resources :tender_attempts, only: [:index, :create], controller: 'workspaces/tender_attempts' do
                member do
                  post :confirm, to: 'workspaces/tender_attempts#confirm'
                  post :cancel, to: 'workspaces/tender_attempts#cancel'
                  get :vietqr, to: 'workspaces/tender_attempts#vietqr'
                end
              end
              post 'funds/allocate', to: 'workspaces/funds#allocate'
              post 'funds/reverse', to: 'workspaces/funds#reverse'
              post 'complete', to: 'workspaces/completions#create'
              post 'trace_allocations', to: 'workspaces/trace_allocations#create'
              get 'credit', to: 'workspaces/credit_approvals#index'
              post 'credit_approvals', to: 'workspaces/credit_approvals#create'
              post 'credit_requests', to: 'workspaces/credit_approvals#request_approval'
              post 'quick_credit', to: 'workspaces/credit_approvals#quick'
              post 'delivery', to: 'workspaces/deliveries#assign'
              post 'delivery/clear', to: 'workspaces/deliveries#clear'
              post 'order_source', to: 'workspaces/order_sources#assign'
              patch 'service_mode', to: 'workspaces/service_modes#update'
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
  # Customer display: read-only, display-token channel outside the Admin API.
  # The buyer's own e-invoice details page behind the QR on the bill (HTML).
  get 'pos_einvoice/:token', to: 'spree/pos/einvoice_buyer#show', as: :pos_einvoice_buyer, constraints: { token: %r{[^/]+} },
                             format: false
  post 'pos_einvoice/:token', to: 'spree/pos/einvoice_buyer#update', constraints: { token: %r{[^/]+} }, format: false

  get 'api/v3/pos_display/state', to: 'spree/pos/display_views#show', defaults: { format: 'json' }
  post 'api/v3/pos_display/ack', to: 'spree/pos/display_views#ack', defaults: { format: 'json' }
  post 'api/v3/pos_display/pair', to: 'spree/pos/display_views#pair', defaults: { format: 'json' }

  post 'api/v3/pos_device/pair', to: 'spree/pos/device_api/pairings#create', defaults: { format: 'json' }
  get 'api/v3/pos_device/me', to: 'spree/pos/device_api/me#show', defaults: { format: 'json' }
  get 'api/v3/pos_device/staff', to: 'spree/pos/device_api/staff_sessions#index', defaults: { format: 'json' }
  post 'api/v3/pos_device/staff_sessions', to: 'spree/pos/device_api/staff_sessions#create', defaults: { format: 'json' }
  delete 'api/v3/pos_device/staff_sessions', to: 'spree/pos/device_api/staff_sessions#destroy', defaults: { format: 'json' }
  post 'api/v3/pos_device/print_jobs/claim', to: 'spree/pos/device_api/print_jobs#claim', defaults: { format: 'json' }
  post 'api/v3/pos_device/print_jobs/:id/report', to: 'spree/pos/device_api/print_jobs#report', defaults: { format: 'json' }

  # The counter app and POS administration built into the production image,
  # same origin as the API. Declared before the Spree engine mount so no
  # engine route takes their deep links; `format: false` keeps asset
  # extensions inside the splat.
  get '/pos', to: 'spree/pos/selling_app#show', as: :pos_selling_app
  get '/pos/*path', to: 'spree/pos/selling_app#show', format: false
  get '/pos-admin', to: 'spree/pos/admin_app#show', as: :pos_admin_app
  get '/pos-admin/*path', to: 'spree/pos/admin_app#show', format: false

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

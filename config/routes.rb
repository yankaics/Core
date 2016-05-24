Rails.application.routes.draw do
  # API and API Documents
  constraints subdomain: 'api' do
    use_doorkeeper do
      controllers :authorizations => 'oauth/authorizations'
      controllers :applications => 'oauth/applications'
    end

    get '/docs.html' => 'api_docs#explore'
    get '/docs/explorer.html' => 'api_docs#explore'
    get '/api_docs/explorer/oauth_callbacks' => 'api_docs#explorer_oauth_callbacks'

    mount API => '/', as: '/'
  end

  use_doorkeeper do
    controllers :authorizations => 'oauth/authorizations'
    controllers :applications => 'oauth/applications'
  end

  get '/api/docs.html' => 'api_docs#explore'
  get '/api/docs/explorer.html' => 'api_docs#explore', as: :api_explorer
  get '/api_docs/explorer/oauth_callbacks' => 'api_docs#explorer_oauth_callbacks'

  mount API => '/api'

  # Index Page
  root 'pages#index'
  get '/mobile-index' => 'pages#mobile_index'

  # Static Pages
  get '/eula' => 'pages#eula'

  # User
  devise_for :users,
             :controllers => {
               :sessions => "users/sessions",
               :omniauth_callbacks => "users/omniauth_callbacks",
               :registrations => "users/registrations",
               :confirmations => "users/confirmations"
             },
             :path => '',
             :path_names => {
               :sign_in => "login",
               :sign_out => "logout",
               :sign_up => "register"
             }

  devise_scope :user do
    delete 'logout' => 'users/sessions#destroy'
    get '/refresh_it' => 'users/sessions#refresh_it'
  end

  resource :my_account, controller: 'users/my_account', path: 'my-account' do
    resources :emails, controller: 'users/emails'
  end

  get '/user_emails/confirmation' => 'users/emails#confirm'
  get '/user_emails/query_departments' => 'users/emails#query_departments'
  get '/user_emails/email_lookup' => 'users/emails#email_lookup'

  get '/invitations' => 'users/invitations#receive'
  get '/invitations/reject' => 'users/invitations#reject'

  # SSO Endpoints
  get '/_rsa.pub' => 'sso#get_rsa_public_key'
  get '/_sst' => 'sso#get_sst'
  get '/refresh_sst' => 'sso#refresh_sst'
  get '/sso_status' => 'sso#get_sso_status'
  get '/sso_status_iframe' => 'sso#get_sso_status'
  get '/sso_redirect_iframe' => 'sso#get_sso_redirect_iframe'
  get '/sso_new_session' => 'sso#get_sso_new_session'

  # chat daily question route
  resources :chat_daily_questions

  # user manual validation route
  resources :user_manual_validations, only: [:index, :new, :create, :destroy]
  get 'user_manual_validation/thank_you' => 'user_manual_validations#thank_you_page', as: :thank_you_page
  get 'user_manual_validation/sso_new_session' => 'user_manual_validations#sso_login'
  post 'user_manual_validation/update_user_org_code' => 'user_manual_validations#update_user_org_code'
  post 'user_manual_validation/refuse_user' => 'user_manual_validations#refuse_user'

  post 'user_manual_validation/send_success_notification' => 'user_manual_validations#send_success_notification'
  post 'user_manual_validation/send_error_notification' => 'user_manual_validations#send_error_notification'

  get 'user_manual_validations/gender' => 'user_manual_validations#gender'
  post 'user_manual_validation/update_user_gender' => 'user_manual_validations#update_user_gender'

  # change daily question

  get '/send_daily_question' => 'pages#chat_daily_question'

  # Developers
  scope '/developers' do
    resources :applications, :controller => 'oauth/applications'
  end

  # Admin Control Panel
  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  scope '/admin' do
    resources :testing_user_sessions, :controller => 'admin/testing_user_sessions'
  end

  # Sidekiq
  require 'sidekiq/web'
  authenticate :admin, ->(u) { u.root? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

Rails.application.routes.draw do
  constraints subdomain: 'api' do
    mount API => '/', as: '/'
  end

  mount API => '/api'

  root 'pages#index'

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
    get '/refresh_sst' => 'users/sessions#refresh_sst'
    get '/refresh_it' => 'users/sessions#refresh_it'
  end

  get '/_rsa.pub' => 'pages#rsa_public_key'
  get '/_sst' => 'pages#sst'

  use_doorkeeper do
    controllers :authorizations => 'oauth/authorizations'
    controllers :applications => 'oauth/applications'
  end

  devise_for :admins, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  scope '/admin' do
    resources :testing_user_sessions, :controller => 'admin/testing_user_sessions'
  end

  resource :my_account, controller: 'users/my_account' do
    resources :emails, controller: 'users/emails'
  end

  get '/user_emails/confirmation' => 'users/emails#confirm'
  get '/user_emails/query_departments' => 'users/emails#query_departments'
  get '/user_emails/email_lookup' => 'users/emails#email_lookup'

  scope '/developers' do
    resources :applications, :controller => 'oauth/applications'
  end

  get '/eula' => 'pages#eula'

  get '/invitations' => 'users/invitations#receive'
  get '/invitations/reject' => 'users/invitations#reject'

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

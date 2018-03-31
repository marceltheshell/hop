require 'sidekiq/web'

Sidekiq::Web.use Rack::Auth::Basic do |username, password|
  user, pass = ENV["SIDEKIQ"].to_s.split(':')
  (username == user && password == pass)
end if ENV["SIDEKIQ"]

Rails.application.routes.draw do
  #
  # Secret urls
  #
  scope '57fdd10b2eedec451c45ca140a9601e3' do
    mount Sidekiq::Web, at: "/sidekiq"
    get '/reports/users' => 'reports#users'
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      #
      # Auth routes
      #
      post '/auth/token' => 'auth/user_token#create', as: :auth   # used for users
      post '/boot'       => 'auth/boot#create',       as: :boot   # used for service users


      #
      # user routes
      #
      get     '/users',           to: 'users#index',   as: :users
      post    '/users',           to: 'users#create'
      get     '/users/:id',       to: 'users#show',    as: :user
      put     '/users/:id',       to: 'users#update'
      delete  '/users/:id',       to: 'users#destroy'

      #
      # Users' QR/barcodes
      #
      scope '/users/:user_id', as: :users do
        post '/qrcodes/deliver',  to: 'qr_codes#deliver', as: :qrcode_deliver
      end

      #
      # User transactions history
      #
      get   '/users/:user_id/transactions',   to: 'transactions#index',   as: :transactions

      #
      # Account value transactions
      #
      post  '/users/:user_id/charges',   to: 'charges#create',    as: :charges
      post  '/users/:user_id/purchases', to: 'purchases#create',  as: :purchases
      post  '/users/:user_id/credits',   to: 'credits#create',    as: :credits
      post  '/users/:user_id/comps',     to: 'comps#create',      as: :comps

      #
      # DrinkCommand integration
      #
      scope :drinkcommand, as: :drink_command do
        get   '/payment/:session_token',    to: 'drink_command#customer',   as: :payment
        get   '/customer/:session_token',   to: 'drink_command#customer',   as: :customer
        post  '/charge/:session_token',     to: 'drink_command#charge',     as: :charge
        post  '/line_item/:session_token',  to: 'drink_command#line_item',  as: :line_item
      end
    end

    # root secured path, ie: /api
    root to: 'secured#index', as: :secured

    # catch all missing api routes
    match "*path", action: "route_not_found", via: :all
  end

  # root path, ie: /
  root to: proc{[200, {}, ['Hop 9000 at your service.']]}
end

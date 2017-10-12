require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'
  root 'client#main'

  controller :client do
    get 'check_order'
  end

  namespace :api, defaults: {format: :json} do
    resources :accounts do
      get 'orders', on: :member
      get 'sessions', on: :member
      post 'start', on: :member
    end
  end
end

require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'
  root 'client#main'

  controller :client do
    get 'download'
  end

  resources :accounts, only: [:show] do

  end
  resources :templates, only: [:show]

  namespace :api, defaults: {format: :json} do
    resources :accounts do
      get 'orders', on: :member
      get 'sessions', on: :member
    end
    resources :templates do
      post 'start', on: :member
      post 'off', on: :member
    end
  end
  namespace :stat do
    controller :application do
      get 'days'
      get 'all'
      get 'markets'
      get 'spreads'
      get 'volumes'
      get 'configs'
      get 'times'
    end
  end

end

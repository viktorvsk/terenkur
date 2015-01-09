Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  root 'events#index'
  resources :users, except: [:create, :new]
  resources :events

  namespace :api do
    namespace :v1 do
      resources :events, only: [:create]
    end
  end

  ActiveAdmin.routes(self)

end

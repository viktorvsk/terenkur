Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  root 'events#index'
  resources :users, except: [:create, :new]
  resources :events

  ActiveAdmin.routes(self)

end

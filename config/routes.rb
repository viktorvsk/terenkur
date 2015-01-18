search_constraints = lambda do |request|
  city = request.params[:city]
  type = request.params[:type]
  date = request.params[:date]
  return false if city.present? and not city.in? City.pluck(:permalink)
  return false if type.present? and not type.in? EventType.pluck(:permalink)
  return false if date.present? and not date =~ /\A\d\d\d\d-\d\d-\d\d\Z/
  true
end

Rails.application.routes.draw do

  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  root 'events#index'
  resources :users, except: [:create, :new]
  resources :events

  get :dates, to: 'events#dates'

  get '/(:city)/(:date)/(:type)', to: 'events#search', constraints: search_constraints
  get '/(:city)/(:type)', to: 'events#search', constraints: search_constraints
  get '/(:city)/(:date)', to: 'events#search', constraints: search_constraints

  get '/(:date)/(:type)', to: 'events#search', constraints: search_constraints
  get '/(:date)/(:city)', to: 'events#search', constraints: search_constraints

  get '/(:type)/(:date)/(:city)', to: 'events#search', constraints: search_constraints
  get '/(:type)/(:date)', to: 'events#search', constraints: search_constraints
  get '/(:type)/(:city)', to: 'events#search', constraints: search_constraints

  namespace :api do
    namespace :v1 do
      resources :events, only: [:create]
    end
  end

  ActiveAdmin.routes(self)

end

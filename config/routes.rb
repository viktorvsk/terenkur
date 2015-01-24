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
  get 'about' => 'high_voltage/pages#show', id: 'about'
  get 'partners' => 'high_voltage/pages#show', id: 'partners'


  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  root 'events#index'
  post :register_and_order, to: 'events#register_and_order'
  resources :users, except: [:create, :new] do
    member do
      get :orders
    end
  end
  resources :events do
    member do
      post :take_part, to: 'events#take_part', as: :order
      post :comments, to: 'events#create_comment', as: :comments
    end
  end

  get :dates, to: 'events#dates'

  get '/(:city)/(:date)/(:type)', to: 'events#search', constraints: search_constraints, as: :search
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

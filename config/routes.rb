Rails.application.routes.draw do
  devise_for :users
  resources :plans, only: [:show, :new] do
    get :jmt, on: :collection
    get :welcome, on: :collection
    get :print, on: :member
    get :mobile, on: :member
    get :new2, on: :member
  end

  get '/', to: 'plans#jmt'

  namespace :api do
    namespace :v1 do
      resources :bookmarklets, only: [:show]
      resources :items, only: [:create], action: 'options', constraints: {:method => 'OPTIONS'}
      
      resources :legs, only: [] do
        get :map, on: :member
      end
      
      resources :days, only: [] do
        get :map, on: :member
      end
    end
  end
end

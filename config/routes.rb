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
      resources :bookmarklets, only: [:show] do
        match '/base' => 'bookmarklets#base', on: :collection, via: [:options, :get]
        match '/save_item' => 'bookmarklets#save_item', on: :collection, via: [:options, :post]
      end

      resources :users, only: [] do
        resources :marks, only: [] do
          match '/create' => 'users/marks#create', on: :collection, via: [:options, :post]
          match '/scrape' => 'users/marks#scrape', on: :collection, via: [:options, :post]
        end
      end
      
      resources :legs, only: [] do
        get :map, on: :member
      end
      
      resources :days, only: [] do
        get :map, on: :member
      end
    end
  end
end

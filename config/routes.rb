Rails.application.routes.draw do
  devise_for :users
  resources :plans, only: [:show, :new] do
    get :welcome, on: :collection
    get :print, on: :member
    get :mobile, on: :member
    get :new2, on: :collection
  end

  devise_scope :user do
    get '/', to: "devise/sessions#new"
  end

  resources :users, only: [] do
    get :bucket, on: :member
  end

  namespace :api do
    namespace :v1 do
      resources :bookmarklets, only: [] do
        match '/script' => 'bookmarklets#script', on: :collection, via: [:options, :get]
        match '/view' => 'bookmarklets#view', on: :collection, via: [:options, :get]
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

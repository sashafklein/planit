Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users

  root 'landing#show'

  resources :plans, only: [:show, :new] do
    get :print, on: :member
    get :edit, on: :member
  end

  devise_scope :user do
    get '/', to: "devise/sessions#new"
  end

  resources :users, only: [:show] do
    get :bucket, on: :member
  end

  resources :places, only: [:show, :new] do
  end

  namespace :api do
    namespace :v1 do

      resources :allowable_sites, only: [] do
        match '/test' => 'allowable_sites#test', on: :collection, via: [:options, :get]
      end

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

      resources :items, only: [:index, :show]

      resources :places, only: [:show, :index]
    end
  end
end

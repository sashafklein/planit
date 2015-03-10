Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users

  root 'landing#show'
  get '/beta', to: 'statics#beta'
  get '/invite', to: 'statics#invite'
  get '/about', to: 'statics#about'
  get '/save', to: 'places#new'

  get '/legal_support', to: 'statics#legal_support'
  get '/legal/dmca', to: 'statics#dmca'
  get '/legal/privacy', to: 'statics#privacy'

  resources :plans, only: [:show, :new, :index] do
    get :print, on: :member
    get :edit, on: :member
  end

  resources :marks, only: [:show]

  resources :users, only: [:show] do
    get :places, on: :member
    get :guides, on: :member
    get :inbox, on: :member
    post :beta, on: :collection
  end

  resources :places, only: [:show, :new, :index] do
  end

  resources :page_feedbacks, only: [:create]

  namespace :api do
    namespace :v1 do

      resources :allowable_sites, only: [] do
        match '/test' => 'allowable_sites#test', on: :collection, via: [:options, :get]
      end

      resources :bookmarklets, only: [] do
        match '/script' => 'bookmarklets#script', on: :collection, via: [:options, :get]
        match '/test' => 'bookmarklets#test', on: :collection, via: [:options, :get]
        match '/report_error' => 'bookmarklets#report_error', on: :collection, via: [:options, :get]
      end

      resources :users, only: [:show] do
        resources :places, only: [:index], controller: 'users/places'
        resources :marks, only: [] do
          match '/create' => 'users/marks#create', on: :collection, via: [:options, :post]
          match '/scrape' => 'users/marks#scrape', on: :collection, via: [:options, :post]
        end
      end
      
      resources :places, only: [:show, :index]

    end
  end
end

Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users

  root 'landing#show'

  get '/beta', to: 'statics#beta'
  get '/invite', to: 'statics#invite'

  get '/about', to: 'statics#about'
  get '/save', to: 'statics#save'
  get '/button', to: 'statics#button'

  get '/feedback', to: 'statics#feedback'

  get '/import', to: 'statics#about' #NEEDSFOLLOWUP
  get '/export', to: 'statics#about' #NEEDSFOLLOWUP
  # get '/inbox', to: 'users#inbox' #NEEDSFOLLOWUP

  get '/legal_support', to: 'statics#legal_support'
  get '/legal/dmca', to: 'statics#dmca'
  get '/legal/privacy', to: 'statics#privacy'

  resources :plans, only: [:show, :new, :index] do
    get :print, on: :member
    get :edit, on: :member
  end

  resources :marks, only: [:show]

  resources :places, only: [:show, :new, :index]

  resources :users, only: [:show] do
    get :places, on: :member
    get :guides, on: :member
    get :inbox, on: :member
    post :waitlist, on: :collection
    post :invite, on: :collection
  end

  resources :page_feedbacks, only: [:create]

  resources :shares, only: [:create]

  namespace :api do
    namespace :v1 do

      resources :marks, only: [:destroy]
      
      resources :errors, only: [:create]
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

      resources :plans, only: [] do
        resources :places, only: [:index], controller: 'plans/places'
      end
      
      resources :places, only: [:show, :index] do
        get :search, on: :collection
      end

    end
  end
end

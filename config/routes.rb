Rails.application.routes.draw do

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  devise_for :users

  root 'landing#show'

  get '/beta', to: 'statics#beta'
  get '/invite', to: 'statics#invite'
  get '/auto_signin', to: 'statics#auto_signin'

  get '/about', to: 'statics#about'
  get '/save', to: 'statics#save'
  get '/button', to: 'statics#button'

  get '/feedback', to: 'statics#feedback'

  get '/import', to: 'statics#about' #NEEDSFOLLOWUP
  get '/export', to: 'statics#about' #NEEDSFOLLOWUP

  get '/legal_support', to: 'statics#legal_support'
  get '/legal/dmca', to: 'statics#dmca'
  get '/legal/privacy', to: 'statics#privacy'

  # get '/inbox', to: 'users#inbox', as: 'user'
  # get '/nearby', to: 'users#nearby', as: 'user'
  # get '/recent', to: 'users#recent', as: 'user'

  resources :plans, only: [:show, :index] do
    get :print, on: :member
    get :edit, on: :member
  end

  resources :items, only: [:new]

  get 'morph/:id', to: 'morph#new', as: :morph
  delete :unmorph, to: 'morph#destroy'

  resources :marks, only: [:show]

  resources :places, only: [:show, :index]

  resources :users, only: [:show] do
    get :places, on: :member
    get :guides, on: :member
    get :inbox, on: :member
    get :recent, on: :member
    get :nearby, on: :member
    post :waitlist, on: :collection
    post :invite, on: :collection
  end

  resources :page_feedbacks, only: [:create]

  resources :shares, only: [:create]

  resources :oauths, only: [] do
    get :foursquare, on: :collection
    get :foursquare_return, on: :collection
    # get :google, on: :collection
    # get :google_return, on: :collection
  end

  namespace :api do
    namespace :v1 do

      resources :foursquare, only: [] do
        get :search, on: :collection
      end

      resources :notes, only: [:create]

      resources :items, only: [:index]
      
      resources :marks, only: [:destroy, :create, :show] do
        post :choose, on: :member
        post :remove, on: :collection
        post :love, on: :collection
        post :unlove, on: :collection
        post :been, on: :collection
        post :notbeen, on: :collection
        post :note, on: :collection
      end
      
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
        resources :plans, only: [:index], controller: 'users/plans'
        resources :marks, only: [] do
          match '/create' => 'users/marks#create', on: :collection, via: [:options, :post]
          match '/scrape' => 'users/marks#scrape', on: :collection, via: [:options, :post]
          match '/mini_scrape' => 'users/marks#mini_scrape', on: :collection, via: [:options, :get]
        end
      end

      resources :plans, only: [:destroy, :create, :show] do
        post :rename, on: :member
        post :add_items, on: :member
        post :destroy_items, on: :member
        post :add_item_from_place_data, on: :member
        resources :places, only: [:index], controller: 'plans/places'
      end
      
      resources :places, only: [:show, :index] do
        get :search, on: :collection
      end

    end
  end

  unless Rails.env.development?
    get '*unmatched_route', to: 'application#catch_404_error'
  end
end

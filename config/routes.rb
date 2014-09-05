Rails.application.routes.draw do
  resources :plans, only: [:show, :new] do
    get :jmt, on: :collection
    get :welcome, on: :collection
    get :print, on: :member
  end

  get '/', to: 'plans#jmt'

  namespace :api do
    namespace :v1 do
      resources :bookmarklets, only: [:show]
      resources :items, only: [:create], action: 'options', constraints: {:method => 'OPTIONS'}
    end
  end
end

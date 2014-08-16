Rails.application.routes.draw do
  resources :itineraries, only: [:show] do
    get :jmt, on: :collection
  end

  get '/', to: 'itineraries#jmt'
end

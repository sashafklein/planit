Rails.application.routes.draw do
  resources :plans, only: [:show, :new] do
    get :jmt, on: :collection
    get :welcome, on: :collection
    get :print, on: :member
  end

  get '/', to: 'plans#jmt'
end

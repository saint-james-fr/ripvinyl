Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  resources :releases, only: %i[ index edit] do
    member do
      get :ripped
      get :rip_later
    end
  end

  post 'update_collection', to: 'releases#update_collection'
  get 'four_to_the_floor', to: 'releases#four_to_the_floor'

  root to: 'pages#home'

  get 'error', to: 'pages#error'
  get 'authenticate', to: 'discogs#authenticate'
  get 'callback', to: 'discogs#callback'
  get 'collection', to: 'discogs#collection'

end

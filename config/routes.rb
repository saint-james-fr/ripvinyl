Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  resources :releases, only: %i[ index edit update] do
    member do
      get :ripped
    end
  end

  root to: "pages#home"

  get 'error', to: 'pages#error'
  get 'authenticate', to: 'discogs#authenticate'
  get 'callback', to: 'discogs#callback'
  get 'collection', to: 'discogs#collection'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end

Rails.application.routes.draw do  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :users do
    resources :products
  end
  get '/products', to: 'products#index'
  post '/products', to: 'products#create'
  get 'login', to: redirect('/auth/google_oauth2')
  get 'logout', to: 'sessions#destroy'
  get 'auth/google_oauth2/callback', to: 'sessions#create'
  get 'auth/failure', to: redirect('/')
  resource :sessions, only: %i[create destroy]

  root to: 'home#index'
end

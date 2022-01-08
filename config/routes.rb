Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  concern :routes do
    resources :flowers, only: [:index, :show] do
      resources :sightings, only: [:index, :create, :destroy] do
        match "likes" => "likes#destroy", via: :delete

        resources :likes, only: [:create]
      end
    end

    post '/register', to: 'users#create'
    post '/login', to: 'sessions#create'
    delete '/logout', to: 'sessions#destroy'
    get '/profile', to: 'sessions#show'
  end

  namespace :api do
    namespace :v1 do
      concerns :routes
    end
  end

end

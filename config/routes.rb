Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      post '/signup', to: 'users#signup'
      get '/users/:user_id', to: 'users#show'
      patch '/users/:user_id', to: 'users#update'
      post '/close', to: 'users#close'
    end
  end
end


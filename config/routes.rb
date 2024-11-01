Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "profile#index" 

  get '/login', to: 'sessions#new', as: 'login'
  post '/auth/ldap', to: 'sessions#create', as: 'new_session' # Comment when SSO!
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/:provider/callback', to: 'sessions#create' # remove after https://github.com/omniauth/omniauth/pull/1106
  get '/auth/failure', to: 'sessions#failure'
  post '/logout', to: 'sessions#destroy', as: 'logout'

  resources :tokens, only: [:index, :new, :create, :destroy]

  resources :ssh_preferences, only: [:index]
  resources :ssh_keys, only: [:new, :create, :destroy]

  resources :users, only: [:index, :show] do
    member do 
      post 'activate'
      post 'deactivate'
    end
  end
  resources :roles
  resources :audit_logs, only: [:index]
  resources :accesses, only: [:new, :create, :destroy] do
    member do
      get 'comment' # for access revoke and decline
      post 'approve'
    end
  end
  # resources :users, only: [:index, :show]
  resources :permissions, only: [:index, :new, :create, :destroy]
  
  namespace :api do
    namespace :v1 do
      get '/systems', to: 'systems#index'
      get '/roles/:id', to: 'roles#show'
      post '/roles', to: 'roles#create'
      patch '/roles/:id', to: 'roles#update'
      delete '/roles/:id', to: 'roles#destroy'
      namespace :users do
        get '/:id/sshkeys', to: 'sshkeys#show'
        post '/:id/sshkeys', to: 'sshkeys#create'
        delete '/:id/sshkeys', to: 'sshkeys#destroy'
        
        get '/:id/accesses', to: 'accesses#show'
        post '/:id/accesses', to: 'accesses#create'
      end
    end
  end
end


Rails.application.routes.draw do
  post '/signup', to: 'auth#signup'
  post '/login', to: 'auth#login'
  
  resources :workspaces do
    member do
      post :join
      get :progress
      get :member_progress
    end
    resources :tasks, only: [:create, :update, :destroy]
  end
end

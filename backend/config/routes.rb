Rails.application.routes.draw do
  post '/signup', to: 'auth#signup'
  post '/login', to: 'auth#login'
  
  resources :workspaces, only: [:index, :show, :create] do
    collection do
      get :available
    end
    member do
      post :join
      get :progress_summary
    end
    resources :tasks, only: [:create, :update, :destroy]
  end
end

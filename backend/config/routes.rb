Rails.application.routes.draw do
  post '/signup', to: 'auth#signup'
  post '/login', to: 'auth#login'
  
  resources :workspaces do
    collection do
      get :available
    end
    member do
      post :join
      get :progress
      get :member_progress
      get :progress_summary
    end
    resources :tasks, only: [:create, :update, :destroy]
  end
end

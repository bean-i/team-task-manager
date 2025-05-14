Rails.application.routes.draw do
  post '/signup', to: 'auth#signup'
end

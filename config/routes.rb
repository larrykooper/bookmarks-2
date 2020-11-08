Rails.application.routes.draw do
  devise_for :users

  root to: "bookmarks#index"
  resources :bookmarks
  post '/bookmarks/:id', to: 'bookmarks#update'

  resources :user_visits

  get "/specials/vnsinro"
  get "/specials/showinro"
  get "/specials/random"
  get "/specials/refreshtags"
  get "/tags/index"

end

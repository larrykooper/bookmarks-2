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
  get "/specials/bulktagrename"
  get "/tags/index"
  post "/specials/bulktagrename_action", to: 'specials#bulktagrename_action'


end

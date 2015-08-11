Rails.application.routes.draw do
  get '/teams' => "home#teams"
  get '/stats' => "home#stats"

  # Application homepage
  root 'home#index'

  # Login pages
  devise_for :users, controllers: { sessions: "users/sessions" }, skip: [ :sessions ]
  devise_scope :user do
    get    "login"   => "users/sessions#new",         as: :new_user_session
    post   "login"   => "users/sessions#create",      as: :user_session
    delete "signout" => "users/sessions#destroy",     as: :destroy_user_session
  end
end

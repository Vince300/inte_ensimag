Rails.application.routes.draw do
  get '/teams' => "home#teams"
  get '/stats' => "home#stats"
  get '/rewards' => "home#rewards"

  # Event streaming
  get '/events' => "home#events"

  # Admin routes, require authentication
  authenticate :user do
    get '/admin' => "home#admin",    as: :admin
    post '/points' => "home#points", as: :points
  end

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

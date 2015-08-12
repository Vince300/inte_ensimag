Rails.application.routes.draw do
  # Application homepage
  root 'home#index'

  draw_routes = Proc.new do
    get '/teams' => "home#teams", as: :teams
    get '/stats' => "home#stats", as: :stats
    get '/rewards' => "home#rewards", as: :rewards

    # Event streaming
    get '/events' => "home#events", as: :events

    # Admin routes, require authentication
    authenticate :user do
      get '/admin' => "home#admin",    as: :admin
      post '/points' => "home#points", as: :points
    end

    # Login pages
    devise_for :users, controllers: { sessions: "users/sessions" }, skip: [ :sessions ]
    devise_scope :user do
      get    "login"   => "users/sessions#new",         as: :new_user_session
      post   "login"   => "users/sessions#create",      as: :user_session
      delete "signout" => "users/sessions#destroy",     as: :destroy_user_session
    end
  end

  if Rails::configuration.application_prefix
    scope Rails::configuration.application_prefix do
      draw_routes.call
    end
  else
    draw_routes.call
  end
end

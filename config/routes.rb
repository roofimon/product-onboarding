Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Registration routes
  get "signup", to: "registrations#new", as: :signup
  post "signup", to: "registrations#create"
  get "registration/completed", to: "registrations#completed", as: :registration_completed

  # Authentication routes
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :logout

  # Home route
  get "home", to: "home#index", as: :home_index

  # Admin routes
  get "admin", to: "admin#dashboard", as: :admin_dashboard
  get "admin/dashboard", to: "admin#dashboard"
  
  namespace :admin do
    resources :users, only: [:index] do
      member do
        patch :approve
        patch :deactivate
        patch :activate
      end
    end
  end

  # Defines the root path route ("/")
  root "sessions#new"
end

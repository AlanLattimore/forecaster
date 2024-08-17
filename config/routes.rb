Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get "forecast", to: "forecast#new"
  post "forecast", to: "forecast#create"

  # Defines the root path route ("/")
  root "forecast#new"
end

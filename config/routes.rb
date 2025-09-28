Rails.application.routes.draw do
  resources :rooms, only: :show
  resources :media_files, only: %i[ new create ]

  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check
end

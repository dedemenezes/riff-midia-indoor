Rails.application.routes.draw do
  authenticated :user, ->(u) { u.admin? } do
    mount_avo
  end
  resources :rooms, only: :show
  resources :presentations, only: %i[ new create ]

  devise_for :users
  root to: "pages#home"

  get "up" => "rails/health#show", as: :rails_health_check
end

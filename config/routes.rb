Rails.application.routes.draw do
  authenticated :user, ->(u) { u.admin? } do
    mount_avo
    mount MissionControl::Jobs::Engine, at: "/jobs"
  end
  get '/avo', to: redirect('/users/sign_in')
  get '/jobs', to: redirect('/users/sign_in')

  resources :rooms, only: :show
  # resources :presentations, only: %i[ new create ]

  devise_for :users
  root to: "presentations#index"

  get "up" => "rails/health#show", as: :rails_health_check
end

Rails.application.routes.draw do
  authenticated :user, ->(u) { u.admin? } do
    mount_avo
    mount MissionControl::Jobs::Engine, at: "/jobs"
    if defined? ::Avo
      Avo::Engine.routes.draw do
        # This route is not protected, secure it with authentication if needed.
        get "presentation_importer", to: "tools#presentation_importer", as: :presentation_importer
        post "presentation_importer", to: "tools#create_presentations_importer", as: :create_presentation_importer
      end
    end
  end
  get '/avo', to: redirect('/users/sign_in')
  get '/jobs', to: redirect('/users/sign_in')

  resources :rooms, only: :show
  resources :static_presentations, only: :show
  # resources :presentations, only: %i[ new create ]

  devise_for :users
  root to: "presentations#index"

  get "up" => "rails/health#show", as: :rails_health_check

  post "/js-alive", to: ->(env) { [200, {}, ["ok"]] }
end

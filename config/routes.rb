Rails.application.routes.draw do
  devise_for :users,
              controllers: { sessions: 'api/v1/users/sessions', registrations: 'api/v1/users/registrations' }
  devise_scope :user do
    post 'signup', to: 'api/v1/users/registrations#create'
    post 'login', to: 'api/v1/users/sessions#create'
    delete 'logout', to: 'api/v1/users/sessions#destroy'
  end
  namespace :api do
    namespace :v1 do
      resources :tests, only: [:index]
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
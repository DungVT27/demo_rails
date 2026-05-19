Rails.application.routes.draw do
  # Devise authentications
  devise_for :users

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check

  # Public / User Interfaces
  root "stores#index"
  resources :stores, only: [:index, :show]
  resources :bookings, only: [:index, :create] do
    member do
      patch :cancel
    end
  end

  # Admin Interfaces (Namespace)
  namespace :admin do
    get "/" => "dashboard#index", as: :dashboard
    resources :stores
    resources :users, only: [:index, :show, :destroy] do
      collection do
        delete :bulk_destroy
      end
    end
    resources :bookings, only: [:index, :show] do
      member do
        patch :cancel
        patch :complete
      end
    end
  end

  # RESTful JSON API
  namespace :api, defaults: { format: :json } do
    resources :stores, only: [:index, :show]
    resources :bookings, only: [:index, :create, :update]
  end
end

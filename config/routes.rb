Rails.application.routes.draw do
  resources :reviews
  resources :orders
  resources :line_items
  resources :carts
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users,
    path: '',
    path_names: {sign_in: 'login', sign_out: 'logout', edit: 'profile', sign_up: 'registration'},
    controllers: {omniauth_callbacks: 'omniauth_callbacks', registrations: 'registrations'}

  resources :users do
    resources :reviews
  end

  resources :products do
    resources :reviews
    resources :favorites, only: [:create, :destroy], shallow: true
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'products#index'

  get "search", to: "search#search"

  get "purchase_history", to: "users#purchase_history"
  get "chat", to: "users#chat"

  get "product_for_women", to: "products#product_for_women"
  get "product_for_men", to: "products#product_for_men"
  get "sneakers_product", to: "products#sneakers_product"
  get "sandals_product", to: "products#sandals_product"
  get "shoes_product", to: "products#shoes_product"
  get "boots_product", to: "products#boots_product"
  get "flip_flops_product", to: "products#flip_flops_product"

  resources :conversations, only: [:create] do
    member do
      post :close
    end

    resources :messages, only: [:create]
  end

  get "recommend_product", to: "users#recommend_product"
end

Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :users

  root "home#index"

  resources :products, only: %i[index show]
  resources :categories, only: :show
  resource :cart, only: :show
  resources :cart_items, only: %i[create update destroy]
  resources :orders, only: %i[index show]
  resource :account, only: %i[edit update]

  resource :checkout, only: %i[new create] do
    get :success
    get :cancel
  end

  get "about", to: "pages#show", defaults: { slug: "about" }, as: :about
  get "contact", to: "pages#show", defaults: { slug: "contact" }, as: :contact
  get "pages/:slug", to: "pages#show", as: :page
  get "up", to: proc { [200, {}, ["ok"]] }
end

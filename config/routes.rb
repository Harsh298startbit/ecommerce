Rails.application.routes.draw do
  get 'pages/about'
  get 'pages/blog'
  get 'pages/contact'
  post 'pages/contact', to: 'pages#contact_submit'
  post 'subscribe', to: 'pages#subscribe'
  # Authentication routes
  get 'signup', to: 'users#new'
  post 'signup', to: 'users#create'
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  # Admin routes
  namespace :admin do
    root 'dashboard#index'
    resources :products
    resources :orders, only: [:index, :show, :update]
    resources :users do
      post :toggle_admin, on: :member
    end
  end
  
  # Cart routes
  resource :cart, only: [:show] do
    delete :clear, on: :member
  end
  resources :cart_items, only: [:create, :update, :destroy]
  
  # Wishlist routes
  resources :wishlist_items, only: [:index, :create, :destroy]
  
  # Order and Payment routes
  resources :orders do
    get 'checkout', on: :member
    get 'payment_intent', on: :member
  end
  post 'payments', to: 'payments#create'
  post 'webhooks/stripe', to: 'payments#webhook'
  
  resources :products
  resources :collections
  get 'shop', to: 'collections#index', as: 'shop'
  
  root 'home#index'
  get 'home/index'
  get 'home/show'
  get 'home/new'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

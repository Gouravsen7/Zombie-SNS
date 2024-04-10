Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :survivors, expect: :destroy do 
  	get 'report', on: :collection
  end
  resources :reported_survivors, only: [:create]
  post 'items/trade_items', to: "items#trade_items"
end

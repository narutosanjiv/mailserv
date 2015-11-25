Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :administrators, except: [:new, :edit]

  root 'dashboard#index'
end

Rails.application.routes.draw do
  resource :session, only: [:new, :create, :destroy]
  resources :administrators, except: [:new, :edit]
      
  resources :domains, except: [:new, :edit] do
    resources :users
    resources :forwardings  
  end

  root 'dashboard#index'
end

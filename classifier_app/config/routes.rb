Rails.application.routes.draw do

  root   'static_pages#home'

  get    'sessions/new'
  get    'users/new'

  get    '/create',  to: 'classifier_request#create'
  post   '/create',  to: 'classifier_request#create'
  get    '/request', to: 'classifier_request#req'
  get    '/result',  to: 'classifier_request#result'


  get    '/help',     to: 'static_pages#help'
  get    '/about',    to: 'static_pages#about'
  get    '/contact',  to: 'static_pages#contact'
  get    '/download', to: 'static_pages#down'
  get    '/signup',   to: 'users#new'
  post   '/signup',   to: 'users#create'
  post   '/del',      to: 'users#del'
  get    '/login',    to: 'sessions#new'
  post   '/login',    to: 'sessions#create'
  delete '/logout',   to: 'sessions#destroy'
  
  #get "*any", via: :all, to: 'application#page_not_found'
  
  resources :users

end

Rails.application.routes.draw do
  root to: 'events#index'
  devise_for :users
  resources :events, except: :show do
    get 'all', on: :collection
  end
  resources :recurring_events, except: :show do
    get 'all', on: :collection
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  resources :regimes do
    resources :permits
    resources :permit_categories
    resources :transactions, only: [:index, :show, :edit, :update]
    resources :history, only: [:index, :show]
  end

  root to: 'transactions#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

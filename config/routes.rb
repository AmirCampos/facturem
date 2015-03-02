Rails.application.routes.draw do
  root 'invoices#index'
  get 'help' => 'help#index'
  get 'customers', to: 'customers#index'
  resources :invoices
end

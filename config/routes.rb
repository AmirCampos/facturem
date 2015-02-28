Rails.application.routes.draw do
  root 'invoices#index'

  get 'invoices/index'
  get 'invoices/show'
  post 'invoices/new'

  get 'customers/index'

  get 'help/index'
  get 'help' => 'help#index'
  get 'customers' => 'customers#index'

  resources :invoices
end

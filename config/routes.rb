Rails.application.routes.draw do
  root 'invoices#index'
  get 'customers' => 'customers#index'
  get 'help' => 'help#index'

  get 'invoices/index'
  get 'invoices/show'
  post 'invoices/new'

  get 'customers/index'

  get 'help/index'

  resources :invoices
end

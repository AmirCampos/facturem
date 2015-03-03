Rails.application.routes.draw do
  root 'invoices#index'

  get 'help' => 'help#index'

  get 'customers', to: 'customers#index'

  get 'invoices/:id/download_csv', to: 'invoices#download_csv', as: 'invoices_download_csv'
  get 'invoices/:id/download_xml', to: 'invoices#download_xml', as: 'invoices_download_xml'
  get 'invoices/:id/download_xsig', to: 'invoices#download_xsig', as: 'invoices_download_xsig'
  get 'invoices/:id/sign', to: 'invoices#sign', as: 'invoices_sign'
  get 'invoices/:id/render_pdf', to: 'invoices#render_pdf', as: 'invoices_render_pdf'
  resources :invoices

  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'
end

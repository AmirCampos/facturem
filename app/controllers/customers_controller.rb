class CustomersController < ApplicationController
  def index
    @page_title = 'Customers';
    @customers = Customer.all
  end
end

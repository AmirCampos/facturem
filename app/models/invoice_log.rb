class InvoiceLog < ActiveRecord::Base
  belongs_to :invoices
end

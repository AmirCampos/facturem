class InvoicesGrid

  include Datagrid

  attr_accessor :issuer

  scope do
    # TODO: current isssuer
    Invoice.order(invoice_date: :desc)
  end

  column(:customer_name)
  column(:invoice_number)
  column(:invoice_date)
  column(:subject)
  column(:amount)
  column(:is_signed) do
    is_signed ? "Yes" : "No"
  end
  column(:is_presented) do
    is_presented ? "Yes" : "No"
  end

  column(:View, :html => true) do |record|
    link_to "Details", invoice_path(record)
  end

  column(:Sign, :html => true) do |record|
    # TODO: path to sign
    link_to "Sign invoice", invoice_path(record)
  end

  def column_class(invoice)
    (invoice.is_signed ? "green" : "red")
  end

end

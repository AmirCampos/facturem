class InvoicesGrid

  include Datagrid

  attr_accessor :issuer

  scope do
    Invoice.joins(:customer).order("invoices.invoice_date desc")
    # Invoice.order(invoice_date: :desc)
  end

  # filter(:is_signed, :boolean)

  column(:customer_name)
  column(:invoice_serie)
  column(:invoice_num)
  column(:invoice_date) do
    invoice_date.to_s(:spanish)
  end
  column(:subject)
  column(:amount) do
    Invoice.format_currency(amount)
  end

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
    (record.is_signed ? "already signed" : link_to("Sign invoice",invoices_sign_path(record)))
  end

  def column_class(invoice)
    (invoice.is_signed ? "signed" : "unsigned")
  end

end

require 'csv_validator'
require 'xml_generator'

class InvoicesController < ApplicationController
  def new
    @page_title = 'Upload invoice'
    @issuer = Issuer.first
    @invoice = @issuer.invoices.new
  end

  def create
    @issuer = Issuer.first
    @invoice = @issuer.invoices.new
    if params[:invoice] == nil
      flash[:alert] = "Please, select a valid file"
      render('new')
      return
    end
      
    @invoice.csv = params[:invoice][:csv].read
    @xml_generator = XMLgenerator::Generator.new
    @validator = CSVvalidator::Validator.new(@invoice.csv,@xml_generator)
    unless @validator.valid?
      flash[:alert] = "Please, check errors"
      # binding.pry
      @errors = @validator.errors.full_messages
      render('new')
      return
    end

    xml = @xml_generator.generate_xml

    @invoice.customer_id = @xml_generator.header.customer.id
    @invoice.invoice_serie = @xml_generator.header.invoice_serie
    @invoice.invoice_num = @xml_generator.header.invoice_number
    @invoice.invoice_date = @xml_generator.header.invoice_date
    @invoice.subject = @xml_generator.header.invoice_subject
    @invoice.amount = @xml_generator.total.total_invoice
    @invoice.xml = xml

    if @invoice.save
      flash[:notice] = "Invoice uploaded successfully"
      # render('show') # show just uploaded invoice
      redirect_to invoice_path(@invoice)
    else
      flash[:error] = "Please, check errors"
      render('new')
    end
  end

  def update
    # @invoice = Invoice.find(params[:id])
    # @invoice.update(get_params)
    # flash[:notice] = 'Invoice Updated'
    # redirect_to invoices_path
  end

  def edit
    # @invoice = Invoice.find(params[:id])
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy
    flash[:notice] = 'Invoice Removed'
    redirect_to invoices_path
  end

  def index
    issuer = Issuer.first
    # @invoices = @issuer.invoices.all.order(invoice_date: :desc)
    # aparams = .merge(issuer_id: issuer.id)
    @grid = InvoicesGrid.new(params[:invoices_grid]) do |scope|
      scope.where(issuer_id: Issuer.first.id).page(params[:page])
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
    unless @invoice.is_valid_xml
      flash[:error] = "Internal error in this invoice"
      redirect_to invoices_path
    end
  end

  def download_csv
    invoice = Invoice.find(params[:id])
    file_name = build_tmp_file_name(invoice, "csv")
    send_file(
      file_name,
      type: "application/csv",
      x_sendfile: true
    )
  end

  def download_xml
    invoice = Invoice.find(params[:id])
    file_name = build_tmp_file_name(invoice, "xml")
    send_file(
      file_name,
      type: "application/xml",
      x_sendfile: true
    )
  end

  def download_xsig
    invoice = Invoice.find(params[:id])
    file_name = build_tmp_file_name(invoice, "xsig")
    send_file(
      file_name,
      type: "application/xsig",
      x_sendfile: true
    )
  end

  def sign
    # TODO: sign
    render 'shared/not_implemented'
  end

  def render_pdf
    # TODO: render pdf
    render 'shared/not_implemented'
  end

  private

  def build_tmp_file_name(invoice, ext)
    field = invoice.attributes[ext]
    file_name = "#{Rails.root}/tmp/invoice_#{invoice.id}.#{ext}"
    File.open(file_name, 'w') { |file| file.write(field) }
    file_name
  end
end

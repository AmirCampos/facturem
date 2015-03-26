require 'csv_validator'
require 'xml_generator'

class InvoicesController < ApplicationController
  def new
    @page_title = 'Upload invoice'
    @issuer = current_issuer
    @invoice = @issuer.invoices.new
  end

  def create
    @issuer = current_issuer
    @invoice = @issuer.invoices.new
    if params[:invoice] == nil
      flash[:alert] = "Please, select a valid file"
      render('new')
      return
    end

    @invoice.csv = params[:invoice][:csv].read
    @xml_generator = XMLgenerator::Generator.new
    @validator = CSVvalidator::Validator.new(@invoice.csv,@xml_generator,@issuer)
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
      flash[:alert] = "Please, check errors"
      render('new')
    end
  end

  def update
    # not necessary at the moment
  end

  def edit
    # not necessary at the moment
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy
    flash[:notice] = 'Invoice Removed'
    redirect_to invoices_path
  end

  def index
    unless logged_in?
      redirect_to login_path
      return
    end

    flash[:alert] = nil

    @current_issuer = current_issuer
    @grid = InvoicesGrid.new(params[:invoices_grid]) do |scope|
      # params[:signed]
      options = {issuer_id: @current_issuer.id}
      where_like = ""

      options[:is_signed] = true if params[:signed].present?
      options[:is_presented] = true  if params[:presented].present?
      if params[:filter_text].present?
        where_like = 'customers.name ILIKE ?'
        like = params[:filter_text]
      end
      if where_like.blank?
        scope.where(options).page(params[:page])
      else
        scope.where([where_like,'%'+like+'%']).where(options).page(params[:page])
      end
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
    unless @invoice.is_valid_xml
      flash[:alert] = "Internal error in this invoice"
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
    save_download_log(invoice,"CSV")
    # render "show"
  end

  def download_xml
    invoice = Invoice.find(params[:id])
    file_name = build_tmp_file_name(invoice, "xml")
    send_file(
      file_name,
      type: "application/xml",
      x_sendfile: true
    )
    save_download_log(invoice,"XML")
    # render "show"
  end

  def download_xsig
    invoice = Invoice.find(params[:id])
    file_name = build_tmp_file_name(invoice, "xsig")
    send_file(
      file_name,
      type: "application/xsig",
      x_sendfile: true
    )
    save_download_log(invoice,"XSIG")
    # render "show"
  end

  def sign
    @invoice = Invoice.find(params[:id])
    render 'sign'
  end

  def signing
    @invoice = Invoice.find(params[:id])
    signature = params[:invoice][:signature]
    is_error = signature != "abcdef"

    unless is_error
      # TODO: real signing
      @invoice.xsig = @invoice.xml + 
      "<signature>"+
      BCrypt::Password.create(signature)+
      "</signature>"
      
      @invoice.is_signed = true
    end

    if @invoice.save && !is_error
      flash[:notice] = "Invoice signed"
      redirect_to(action: 'show')
    else
      flash[:alert] = "Invalid signature"
      render('sign')
    end
  end

  def render_pdf
    # TODO: render pdf
    render 'shared/not_implemented'
    #save_download_log(invoice,"XML")
  end

  def send_to_admin
    # TODO: send to admin
    @invoice = Invoice.find(params[:id])
    @invoice.is_presented = true
    if @invoice.save
      flash[:notice] = "Invoice was sent successfully. Please wait while you are paid"
      redirect_to(action: 'show')
    else
      flash[:alert] = "Sorry, something was wrong"
      render 'show'
    end
  end

  private

  # FIXME: saves TWO times every log
  def save_download_log(invoice,format)
    invoice.invoice_logs.create(
      action: "Downloaded invoice in #{format} format.",
    action_code: InvoiceLog::ACTION_INVOICE_DOWNLOAD)
    invoice.invoice_logs.reload
  end

  def build_tmp_file_name(invoice, ext)
    field = invoice.attributes[ext]
    file_name = "#{Rails.root}/tmp/invoice_#{invoice.id}.#{ext}"
    File.open(file_name, 'w') { |file| file.write(field) }
    file_name
  end

  def edit_params
    params.require(:invoice).permit(:signature)
  end

end

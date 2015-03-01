class InvoicesController < ApplicationController
  def new
    @page_title = 'Upload invoice'
    # TODO: QUESTION where put current issuer?
    @issuer = Issuer.first
  end

  def create
    csv = get_params[:csv]
    # TODO: change disk file by stream
    csv_file_name = "#{Rails.root}/tmp/tmp.csv"
    File.open(csv_file_name, 'w') { |file| file.write(csv) }

    @xml_generator = XMLgenerator::Generator.new
    @validator = CSVvalidator::Validator.new(csv_file_name,@xml_generator)
    if !@validator.validate?
      flash[:error] = "Please, check errors"
      render('new')
    end

    xml = @xml_generator.generate_xml

    @invoice = @issuer.invoices.new
    @invoice.customer_id = @xml_generator.header.customer.id
    @invoice.invoice_serie = @xml_generator.header.invoice_serie
    @invoice.invoice_num = @xml_generator.header.invoice_number
    @invoice.invoice_date = @xml_generator.header.invoice_date
    @invoice.subject = @xml_generator.header.invoice_subject
    @invoice.amount = @xml_generator.total.total_invoice
    @invoice.csv = csv
    @invoice.xml = xml

    if @invoice.save
      redirect_to(action: 'index')
      flash[:notice] = "Invoice uploaded successfully"
      render('show') # show just uploaded invoice
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
    # @invoice = Invoice.find(params[:id])

    # @invoice.destroy

    # flash[:notice] = 'Invoice Removed'

    # redirect_to invoices_path
  end

  def index
    issuer = Issuer.first
    # @invoices = @issuer.invoices.all.order(invoice_date: :desc)
    # aparams = .merge(issuer_id: issuer.id)
    @grid = InvoicesGrid.new(params[:invoices_grid]) do |scope|
      scope.page(params[:page])
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  private
    def get_params
    params.require(:invoice).permit(:csv)
  end
end

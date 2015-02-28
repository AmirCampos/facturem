class InvoicesController < ApplicationController
  def new
    @page_title = 'Upload invoice'
    @invoice = Invoice.new
  end

  def create
    @invoice = Invoice.new(get_params)
    @invoice.save

    flash[:notice] = 'Invoice uploaded'

    redirect_to invoices_path
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
    @issuer = Issuer.first
    @invoices = @issuer.invoices.all.order(invoice_date: :desc)
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  private
    def get_params
    # params.require(:invoice).permit(:title, :category_id, :author_id, :publisher_id, :isbn, :price, :buy, :format, :excerpt, :pages, :year, :coverpath)
  end
end

require 'csv'

module CSVvalidator
  COL_COUNT            = 16
  CURRENT_VERSION      = "v1.0"
  SUPPORTED_ROWS       = (1..5)
  REGEX_OPTIONAL_DATE  = /(|\A\d{4}-\d{2}-\d{2}\z)/
  REGEX_DATE           = /\A\d{4}-\d{2}-\d{2}\z/
  REGEX_AMOUNT_2D      = /\A[-]?([1-9]{1}[0-9]{0,}(\.[0-9]{0,2})?|0(\.[0-9]{0,2})?|\.[0-9]{1,2})\z/
  REGEX_AMOUNT_4D      = /\A[-]?([1-9]{1}[0-9]{0,}(\.[0-9]{0,4})?|0(\.[0-9]{0,4})?|\.[0-9]{1,4})\z/
  REGEX_AMOUNT_6D      = /\A[-]?([1-9]{1}[0-9]{0,}(\.[0-9]{0,6})?|0(\.[0-9]{0,6})?|\.[0-9]{1,6})\z/
  REGEX_TAX            = /\A((100|[1-9]{1}[0-9]{0,1})(\.[0-9]{0,2})?|0(\.[0-9]{0,2})?|\.[0-9]{1,2})\z/
  REGEX_DISCOUNT       = /\A((100|[1-9]{1}[0-9]{0,1})(\.[0-9]{0,2})?|0(\.[0-9]{0,2})?|\.[0-9]{1,2})\z/
  MSG_NOT_VALID_NUMBER = "Is not a valid number, quantity, tax, discount or amount"
  MSG_NOT_VALID_DATE   = "Is not a valid date. Expected format is yyyy-mm-dd"

  def self.add_error(validable,row_counter,field,message)
    line_number = (row_counter > 0 ? "Line #{row_counter}:" : "")
    validable.errors.add(field, "#{line_number}#{message}")
  end

  class Validator
    include ActiveModel::Validations

    validate :do_validations

    def initialize(file_name)
      @file_name = file_name
    end

    private

    def do_validations
      factory = RowValidatorFactory.new(self)
      errors.clear
      row_counter = 1
      begin
        CSV.foreach(@file_name) do |row|
          col_count = row.length
          if col_count < COL_COUNT
            CSVvalidator.add_error(self,row_counter,:file,"Column count #{col_count} is less than minimum #{COL_COUNT}")
            break
          elsif (row_counter == 1) || SUPPORTED_ROWS.include?(row[0].to_i)
            row_validator = factory.create_row_validator(row_counter,row)
            if row_validator.invalid?
              row_validator.errors.each do |k,v|
                CSVvalidator.add_error(self,row_counter,k,v)
              end
              if row_counter == 1
                break
              end
            else
              # TODO: store valid validators for convert to xml
            end
          end
          row_counter += 1
        end
      rescue CSV::MalformedCSVError
        errors.add(:file, "#{@file_name} is not a valid CSV file")
      rescue Errno::ENOENT
        errors.add(:file, "#{@file_name} does not exist")
      end
    end
  end

  class AbstractRowValidator
    include ActiveModel::Validations

    def initialize(owner,row_counter,row)
      @owner = owner
      @row_counter = row_counter
      @row = row
    end

    protected

    def add_error(field,message,options = {})
      line_number = (options[:line_number] ? @row_counter : 0)
      CSVvalidator.add_error(self, line_number, field, message)
    end

  end

  class VersionRowValidator < AbstractRowValidator
    validate :do_validations

    private

    def do_validations
      add_error(:version,"Version #{@row[0]} is not supported",{line_number: false}) unless @row[0] == CURRENT_VERSION
    end
  end

  class InvoiceHeaderRowValidator < AbstractRowValidator
    attr_reader :customer

    attr_reader :issuer_tax_id
    validate :validate_issuer

    attr_reader :customer_id
    validate :validate_customer

    attr_reader :customer_tax_id
    validates :customer_tax_id, presence: true, nif: true

    attr_reader :customer_name
    validates :customer_name, presence: true, length: { in: 4..80}

    attr_reader :customer_accounting_service
    validates :customer_accounting_service, presence: true, length: { in: 0..10}

    attr_reader :customer_management_unit
    validates :customer_management_unit, presence: true, length: { in: 0..10}

    attr_reader :customer_processing_unit
    validates :customer_processing_unit, presence: true, length: { in: 0..10}

    attr_reader :customer_address
    validates :customer_address, length: { in: 0..80}

    attr_reader :customer_postal_code
    validates :customer_postal_code, format: { with: /\A\d{5}\z/, message: "Must be a valid spanish post code" }

    attr_reader :customer_town
    validates :customer_town, length: { in: 0..50}

    attr_reader :customer_province
    validates :customer_province, length: { in: 0..20}

    attr_reader :invoice_serie
    validates :invoice_serie, presence: true, length: { in: 0..20}

    attr_reader :invoice_number
    validates :invoice_number, presence: true, length: { in: 0..20}

    attr_reader :invoice_date
    validates :invoice_date, format: { with: REGEX_DATE, message: MSG_NOT_VALID_DATE }

    attr_reader :invoice_subject
    validates :invoice_subject, length: { in: 0..80}

    def initialize(owner,row_counter,row)
      super
      @issuer_tax_id               = @row[ 1]
      @customer_id                 = @row[ 2]
      @customer_tax_id             = @row[ 3]
      @customer_name               = @row[ 4]
      @customer_accounting_service = @row[ 5]
      @customer_management_unit    = @row[ 6]
      @customer_processing_unit    = @row[ 7]
      @customer_address            = @row[ 8]
      @customer_postal_code        = @row[ 9]
      @customer_town               = @row[10]
      @customer_province           = @row[11]
      @invoice_serie               = @row[12]
      @invoice_number              = @row[13]
      @invoice_date                = @row[14]
      @invoice_subject             = @row[15]
    end

    private

    def validate_issuer
      add_error(:issuer_tax_id, "Issuer #{@issuer_tax_id} is not registered") unless Issuer.find_by(tax_id: @issuer_tax_id)
    end

    def validate_customer
      @customer = Customer.find_by(tax_id: @customer_tax_id)
      # create a customer if not exist. 
      if !@customer
        @customer = Customer.create(
          tax_id: @customer_tax_id,
          name: @customer_name,
          processing_unit: @customer_processing_unit,
          accounting_service: @customer_accounting_service,
          management_unit: @customer_management_unit)
        if !@customer.valid?
          @Customer.errors.each do |k,v|
            add_error(:customer,v)
          end
        end
      end
    end
  end

  class RowValidatorInvoiceDetail < AbstractRowValidator
    attr_reader :article_code
    validates :article_code, presence: true, length: { in: 1..20}

    attr_reader :delivery_note_number
    # has no validation

    attr_reader :delivery_note_date
    validates :delivery_note_date, format: { with: REGEX_OPTIONAL_DATE, message: MSG_NOT_VALID_DATE }

    attr_reader :item_description
    validates :item_description, presence: true, length: { in: 1..80}

    attr_reader :quantity
    validates :quantity, presence: true, format: { with: REGEX_AMOUNT_6D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :unit_price_without_tax
    validates :unit_price_without_tax, presence: true, format: { with: REGEX_AMOUNT_6D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :total_line
    validates :total_line, presence: true, format: { with: REGEX_AMOUNT_4D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :discount_reason
    #has no validation

    attr_reader :discount_rate
    validates :discount_rate, presence: true, format: { with: REGEX_DISCOUNT, message: MSG_NOT_VALID_NUMBER }

    attr_reader :discount_amount
    validates :discount_amount, presence: true, format: { with: REGEX_AMOUNT_6D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :tax_rate
    validates :tax_rate, presence: true, format: { with: REGEX_TAX, message: MSG_NOT_VALID_NUMBER }

    attr_reader :tax_base
    validates :tax_base, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :tax_amount
    validates :tax_amount, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    def initialize(owner,row_counter,row)
      super
      @article_code                 = @row[ 1]
      @delivery_note_number         = @row[ 2]
      @delivery_note_date           = @row[ 3]
      @item_description             = @row[ 4]
      @quantity                     = @row[ 5]
      @unit_price_without_tax       = @row[ 6]
      @total_line                   = @row[ 7]
      @discount_reason              = @row[ 8]
      @discount_rate                = @row[ 9]
      @discount_amount              = @row[10]
      @tax_rate                     = @row[11]
      @tax_base                     = @row[12]
      @tax_amount                   = @row[13]
    end
  end

  class RowValidatorTaxRates < AbstractRowValidator
    attr_reader :tax_rate
    validates :tax_rate, presence: true, format: { with: REGEX_TAX, message: MSG_NOT_VALID_NUMBER }

    attr_reader :tax_base
    validates :tax_base, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :tax_amount
    validates :tax_amount, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    def initialize(owner,row_counter,row)
      super
      @tax_rate                  = @row[ 1]
      @tax_base                  = @row[ 2]
      @tax_amount                = @row[ 3]
    end
  end

  class RowValidatorInvoiceTotals < AbstractRowValidator
    attr_reader :total_gross_amount
    validates :total_gross_amount, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :general_discount_reason
    # has no validations

    attr_reader :general_discount_rate
    validates :general_discount_rate, presence: true, format: { with: REGEX_DISCOUNT, message: MSG_NOT_VALID_NUMBER }

    attr_reader :total_general_discount
    validates :total_general_discount, presence: true, format: { with: REGEX_AMOUNT_6D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :total_amount_before_taxes
    validates :total_amount_before_taxes, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :total_invoice
    validates :total_invoice, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    def initialize(owner,row_counter,row)
      super
      @total_gross_amount        = @row[ 1]
      @general_discount_reason   = @row[ 2]
      @general_discount_rate     = @row[ 3]
      @total_general_discount    = @row[ 4]
      @total_amount_before_taxes = @row[ 5]
      @total_invoice             = @row[ 6]
    end
  end

  class RowValidatorPaymentSchedule < AbstractRowValidator
    attr_reader :installment_due_date
    validates :installment_due_date, presence: true, format: { with: REGEX_DATE, message: MSG_NOT_VALID_DATE }

    attr_reader :installment_due_amount
    validates :installment_due_amount, presence: true, format: { with: REGEX_AMOUNT_2D, message: MSG_NOT_VALID_NUMBER }

    attr_reader :payment_means
    validates :payment_means, presence: true, format: { with: /\A04\z/, message: "Only accepted payment means 04" }

    attr_reader :account_number_to_be_credited
    validates :account_number_to_be_credited, presence: true, format: { with: /\A[a-zA-Z]{2}[0-9]{2}[a-zA-Z0-9]{4}[0-9]{7}([a-zA-Z0-9]?){0,16}\z/, message: "Only accepted valid IBAN" }

    def initialize(owner,row_counter,row)
      super
      @installment_due_date          = @row[ 1]
      @installment_due_amount        = @row[ 2]
      @payment_means                 = @row[ 3]
      @account_number_to_be_credited = @row[ 4]
    end
  end

  class RowValidatorError < AbstractRowValidator
    validate :do_validations

    private

    def do_validations
      add_error(:file,"This row kind #{@row[0]} is not supported")
    end
  end

  class RowValidatorFactory
    def initialize(owner)
      @owner = owner
    end

    def create_row_validator(row_counter,row)
      if is_version?(row[0])
        return VersionRowValidator.new(@owner,row_counter,row)
      else
        case row[0]
        when "1"
          return InvoiceHeaderRowValidator.new(@owner,row_counter,row)
        when "2"
          return RowValidatorInvoiceDetail.new(@owner,row_counter,row)
        when "3"
          return RowValidatorTaxRates.new(@owner,row_counter,row)
        when "4"
          return RowValidatorInvoiceTotals.new(@owner,row_counter,row)
        when "5"
          return RowValidatorPaymentSchedule.new(@owner,row_counter,row)
        else
          return RowValidatorError.new(@owner,row_counter,row)
        end
      end
    end

    private

    def is_version?(cell)
      #v1.0
      (cell =~ /\Av\d\.\d\z/) == 0 ? true : false
    end
  end

end

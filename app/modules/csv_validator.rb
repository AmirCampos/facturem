require 'csv'
# require 'active_model'

module CSVvalidator
  COL_COUNT = 16
  CURRENT_VERSION = "v1.0"
  SUPPORTED_ROWS = (1..5)
  REGEX_OPTIONAL_DATE = /(|\A\d{4}-\d{2}-\d{2}\z)/
  REGEX_DATE = /\A\d{4}-\d{2}-\d{2}\z/

  def self.add_error(active_model,row_counter,field,message)
    active_model.errors.add(field, "Line #{row_counter}: #{message}")
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
              row_validator.errors.each{|k,v| errors.add(k,v)}
              if row_counter == 1
                break
              end
            end
          end
          row_counter += 1
        end
      rescue CSV::MalformedCSVError
        errors.add(:file, "#{@file_name} is not a valid CSV file")
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

    def add_error(field,message)
      CSVvalidator.add_error(self, @row_counter, field, message)
    end

  end

  class VersionRowValidator < AbstractRowValidator
    validate :do_validations

    private

    def do_validations
      add_error(:version,"Version #{@row[0]} is not supported") unless @row[0] == CURRENT_VERSION
    end
  end

  class InvoiceHeaderRowValidator < AbstractRowValidator
    attr_accessor :issuer_tax_id
    validate :validate_issuer
    attr_accessor :customer
    #todo

    attr_reader :invoice_date
    validates :invoice_date, format: { with: REGEX_DATE, message: "Is not a valid date. Must be yyyy-mm-dd" }

    # 1.Issuer TAX ID. Must match with configuration.
    # 2.Customer ID
    # 3.Customer TAX ID
    # 4.Customer name
    # 5.Customer accounting service (oficina contable). Role type = 01
    # 6.Customer management unit  (órgano gestor). Role type = 02
    # 7.Customer processing unit (unidad tramitadora). Role type = 03
    # 8.Customer address
    # 9.Customer postal code
    # 10.Customer town
    # 11.Customer province
    # 12.Invoice serie
    # 13.Invoice number
    # 14.Invoice date
    # 15.Invoice subject

    def initialize(owner,row_counter,row)
      super
      @issuer_tax_id                = @row[ 1]
      # @delivery_note_number         = @row[ 2]
      # @delivery_note_date           = @row[ 3]
      # @item_description             = @row[ 4]
      # @quantity                     = @row[ 5]
      # @unit_price_without_tax       = @row[ 6]
      # @total_line                   = @row[ 7]
      # @discount_reason              = @row[ 8]
      # @discount_rate                = @row[ 9]
      # @discount_amount              = @row[10]
      # @tax_rate                     = @row[11]
      # @tax_base                     = @row[12]
      # @tax_amount                   = @row[13]
      @invoice_date                 = @row[14]
    end

    private

    def validate_issuer
      add_error(:issuer_tax_id, "Issuer #{@issuer_tax_id} is not registered") unless Issuer.find_by(tax_id: @issuer_tax_id)

      # ToDo: create a customer if not exist. If not valid customer, return customer errors.
      # ToDo: Fill customer
    end

  end

  class RowValidatorInvoiceDetail < AbstractRowValidator
    attr_reader :article_code
    validates :article_code, presence: true, length: { in: 1..20}

    attr_reader :delivery_note_number
    # has no validation
    
    attr_reader :delivery_note_date
    validates :delivery_note_date, format: { with: REGEX_OPTIONAL_DATE, message: "Is not a valid date. Must be yyyy-mm-dd" }

    attr_reader :item_description
    validates :item_description, presence: true, length: { in: 1..80}
    #ToDo: more validations

    # 1.Article code
    # 2.Delivery note number. Optional.
    # 3.Delivery note date. Optional.
    # 4.Item description
    # 5.Quantity
    # 6.Unit price without tax
    # 7.Total line
    # 8.Discount reason (text)
    # 9.Discount rate
    # 10.Discount amount
    # 11.Tax rate
    # 12.Tax base
    # 13.Tax amount

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
    def validate_row(row_counter,row)
      # add_error(:tax, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorInvoiceTotals < AbstractRowValidator
    def validate_row(row_counter,row)
      # add_error(:totals, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorPaymentSchedule < AbstractRowValidator
    def validate_row(row_counter,row)
      # add_error(:payment, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorErrror < AbstractRowValidator
    validate :do_validations

    private

    def do_validations
      # add_error(:unknown_row_kind, "Unknown row kind #{row[0]}")
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
          # when "3"
          #   return RowValidatorTaxRates.new(@owner,row_counter,row)
          # when "4"
          #   return RowValidatorInvoiceTotals.new(@owner,row_counter,row)
          # when "5"
          #   return RowValidatorPaymentSchedule.new(@owner,row_counter,row)
        else
          return RowValidatorErrror.new(@owner,row_counter,row)
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

############3
# vali = CSVvalidator::Validator.new(ARGV[0])
# p vali.valid?
# p vali.errors.messages

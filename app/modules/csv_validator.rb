require 'csv'
require 'active_model'

module CSVvalidator
  COL_COUNT = 16
  CURRENT_VERSION = "v1.0"
  SUPPORTED_ROWS = (1..5)

  class Validator
    include ActiveModel::Validations

    def validate_file(file_name)
      factory = RowValidatorFactory.new(self)
      errors.clear
      row_counter = 1
      begin
        CSV.foreach(file_name) do |row|
          col_count = row.length
          if col_count < COL_COUNT
            add_error(row_counter,:file, "Column count #{col_count} is less than minimum #{COL_COUNT}")
            break
          elsif (row_counter == 1) || SUPPORTED_ROWS.include?(row[0].to_i)
            row_validator = factory.create_row_validator(row[0])
            row_validator.validate_row(row_counter,row)
            if (row_counter == 1) && !row_validator.is_valid
              break
            end
          end
          row_counter += 1
        end
      rescue CSV::MalformedCSVError
        errors.add(:file, "#{file_name} is not a valid CSV file")
      end
    end

    def add_error(row_counter,field,message)
      errors.add(field, "Line #{row_counter}: #{message}")
    end

  end

  class AbstractRowValidator
    attr_reader :is_valid
    
    def initialize(owner)
      @owner = owner
      @is_valid = true
    end

    private
    
    def add_error(row_counter,field,message)
      @owner.add_error(row_counter, field, "Line #{row_counter}: #{message}")
      @is_valid = false
    end

  end

  class RowValidatorVersion < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:version,"Version #{row[0]} is not supported") unless row[0] == CURRENT_VERSION
    end
  end

  class RowValidatorInvoiceHeader < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:header, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorInvoiceDetail < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:detail, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorTaxRates < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:tax, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorInvoiceTotals < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:totals, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorPaymentSchedule < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:payment, "This tests col two #{row[1]}")
    end
  end

  class RowValidatorErrror < AbstractRowValidator
    def validate_row(row_counter,row)
      add_error(row_counter,:unknown_row_kind, "Unknown row kind #{row[0]}")
    end
  end

  class RowValidatorFactory
    def initialize(owner)
      @owner = owner
    end

    def create_row_validator(cell)
      if is_version?(cell)
        return RowValidatorVersion.new(@owner)
      else
        case cell
        when "1"
          return RowValidatorInvoiceHeader.new(@owner)
        when "2"
          return RowValidatorInvoiceDetail.new(@owner)
        when "3"
          return RowValidatorTaxRates.new(@owner)
        when "4"
          return RowValidatorInvoiceTotals.new(@owner)
        when "5"
          return RowValidatorPaymentSchedule.new(@owner)
        else
          return RowValidatorErrror.new(@owner)
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
vali = CSVvalidator::Validator.new
vali.validate_file(ARGV[0])
p vali.errors.messages

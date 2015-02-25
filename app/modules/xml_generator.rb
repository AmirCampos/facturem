module XMLgenerator

  class Generator
    attr_accessor :header
    attr_accessor :detail_list
    attr_accessor :tax_list
    attr_accessor :total
    attr_accessor :installment_list

    def initialize
      clear
    end

    def clear
      @header = nil
      @detail_list = []
      @tax_list = []
      @total = nil
      @installment_list = []
    end

    def add_row(row)
      case row.row_kind
      when 1
        @header = row
      when 2
        @detail_list << row
      when 3
        @tax_list << row
      when 4
        @total = row
      when 5
        @installment_list << row
      end
    end

    def generate_xml
      xml = []
      xml << @header
      @detail_list.each do |detail| 
        xml << detail
      end
      @tax_list.each do |tax| 
        xml << tax
      end
      xml << @total
      @installment_list.each do |installment| 
        xml << installment
      end
      xml
    end

  end
end

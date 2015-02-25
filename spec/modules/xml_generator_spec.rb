require 'rails_helper'
require 'csv_validator'
require 'faker'
require "awesome_print"

RSpec.describe XMLgenerator, type: :module do
  describe "Validates XMLgenerator" do

    before do
      issuer = build(:issuer, tax_id: "B57534125")
      issuer.save

      @xml_generator = XMLgenerator::Generator.new
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/3.csv",@xml_generator)
      validator.validate
    end

    it "XML should have customer address" do
      expect(@xml_generator.header.customer_address).to eq "Plaza Constitución, 1"
    end
    
    it "XML should have n detail.lines" do
      expect(@xml_generator.detail_list.size).to eq 2
    end

    it "XML should have n installment_list.lines" do
      expect(@xml_generator.installment_list.size).to eq 3
    end

    it "XML should have have this total amount" do
      expect(@xml_generator.total.total_invoice).to eq "2553.24"
    end

  end
end

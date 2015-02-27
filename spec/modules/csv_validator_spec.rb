require 'rails_helper'
require 'csv_validator'
require 'xml_generator'
require 'faker'

RSpec.describe CSVvalidator, type: :module do
  describe "Validates an imported CSV" do

    before do
      issuer = build(:issuer, tax_id: "B57534125")
      issuer.save

      @xml_generator = XMLgenerator::Generator.new
    end

    it "should be a valid CSV file. 1.csv One item. One tax. No payments. No discounts" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/1.csv",@xml_generator)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should create a non existing customer. '41495761N' 1.csv" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/1.csv",@xml_generator)

      p validator.errors.messages unless validator.valid?
      customer = Customer.find_by(tax_id: "41495761N")
      expect(customer).to be_truthy
    end

    it "should use an existing customer. 'B07079999' 1.csv" do
      customer = Customer.create(
        tax_id: "B07079999",
        name: Faker::Company.name,
        processing_unit: Faker::Number.number(10).to_s,
        accounting_service: Faker::Number.number(10).to_s,
        management_unit: Faker::Number.number(10).to_s)

      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/1.csv",@xml_generator)

      p validator.errors.messages unless validator.valid?
      expect(@xml_generator.header.customer_name).to eq "Ajuntament Maó"
    end

    it "should be a valid CSV file. 2.csv Two items. Two taxes. No payments. No discounts" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/2.csv",@xml_generator)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should be a valid CSV file. 3.csv Two items. Two taxes. With payments. Both discounts" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/3.csv",@xml_generator)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should handle a non existing CSV file" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/not_exist.csv",@xml_generator)

      expect(validator.valid?).to be_falsy
      expect(validator.errors.messages).to include(:file)
    end

    it "should handle a non CSV file. is_not_a_csv.xml" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/is_not_a_csv.xml",@xml_generator)

      expect(validator.valid?).to be_falsy
      expect(validator.errors.messages).to include(:file)
    end

    it "should be a not supported version. bad_version.csv" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/bad_version.csv",@xml_generator)

      expect(validator.valid?).to be_falsy
      # expect(validator.errors.messages).to include(:version)
      expect(validator.errors.messages[:version]).to eq ["Line 1:Version v1.1 is not supported"]
    end

  end
end

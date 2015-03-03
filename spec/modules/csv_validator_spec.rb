require 'rails_helper'
require 'csv_validator'
require 'xml_generator'
require 'faker'

RSpec.describe CSVvalidator, type: :module do
  describe "Validates an imported CSV" do

    before do
      @issuer_B57534125 = build(:issuer, tax_id: "B57534125")
      @issuer_B57534125.save

      @issuer_B07079999 = build(:issuer, tax_id: "B07079999")
      @issuer_B07079999.save

      @xml_generator = XMLgenerator::Generator.new
      @raw_csv_1 = IO.read("#{Rails.root}/spec/fixtures/1.csv")
      @raw_csv_2 = IO.read("#{Rails.root}/spec/fixtures/2.csv")
      @raw_csv_3 = IO.read("#{Rails.root}/spec/fixtures/3.csv")
      @raw_csv_4 = IO.read("#{Rails.root}/spec/fixtures/4.csv")
    end

    it "should be a valid CSV file. 1.csv One item. One tax. No payments. No discounts" do
      validator = CSVvalidator::Validator.new(@raw_csv_1,@xml_generator,@issuer_B57534125)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should not permit upload a CSV from another issuer. 4.csv" do
      validator = CSVvalidator::Validator.new(@raw_csv_4,@xml_generator,@issuer_B57534125)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_falsy
    end

    it "should create a non existing customer. '41495761N' 1.csv" do
      validator = CSVvalidator::Validator.new(@raw_csv_1,@xml_generator,@issuer_B57534125)

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

      validator = CSVvalidator::Validator.new(@raw_csv_1,@xml_generator,@issuer_B57534125)

      p validator.errors.messages unless validator.valid?
      expect(@xml_generator.header.customer_name).to eq "Ajuntament Alaior"
    end

    it "should be a valid CSV file. 2.csv Two items. Two taxes. No payments. No discounts" do
      validator = CSVvalidator::Validator.new(@raw_csv_2,@xml_generator,@issuer_B57534125)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should be a valid CSV file. 3.csv Two items. Two taxes. With payments. Both discounts" do
      validator = CSVvalidator::Validator.new(@raw_csv_3,@xml_generator,@issuer_B57534125)

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should handle an empty file" do
      validator = CSVvalidator::Validator.new("",@xml_generator,@issuer_B57534125)

      expect(validator.valid?).to be_falsy
      expect(validator.errors.messages).to include(:file)
    end

    it "should handle a non CSV file. is_not_a_csv.xml" do
      validator = CSVvalidator::Validator.new(IO.read("#{Rails.root}/spec/fixtures/is_not_a_csv.xml"),@xml_generator,@issuer_B57534125)

      expect(validator.valid?).to be_falsy
      expect(validator.errors.messages).to include(:file)
    end

    it "should be a not supported version. bad_version.csv" do
      bad_version = IO.read("#{Rails.root}/spec/fixtures/bad_version.csv")
      validator = CSVvalidator::Validator.new(bad_version,@xml_generator,@issuer_B57534125)

      expect(validator.valid?).to be_falsy
      # expect(validator.errors.messages).to include(:version)
      expect(validator.errors.messages[:version]).to eq ["Line 1:Version v1.1 is not supported"]
    end

  end
end

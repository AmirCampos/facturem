require 'rails_helper'
require 'csv_validator'

RSpec.describe CSVvalidator, type: :module do
  describe "Validates an imported CSV" do

    before do
      issuer = build(:issuer, tax_id: "B57534125")
      issuer.save
    end

    it "should be a valid CSV file. 1.csv One item. One tax. No payments. No discounts" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/1.csv")

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should be a valid CSV file. 2.csv Two items. Two taxes. No payments. No discounts" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/2.csv")

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should be a valid CSV file. 3.csv Two items. Two taxes. With payments. Both discounts" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/3.csv")

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should handle a non existing CSV file" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/not_exist.csv")

      expect(validator.valid?).to be_falsy
      expect(validator.errors.messages).to include(:file)
    end

    it "should handle a non CSV file. is_not_a_csv.xml" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/is_not_a_csv.xml")

      expect(validator.valid?).to be_falsy
      expect(validator.errors.messages).to include(:file)
    end

    it "should be a not supported version. bad_version.csv" do
      validator = CSVvalidator::Validator.new("#{Rails.root}/spec/fixtures/bad_version.csv")

      expect(validator.valid?).to be_falsy
      # expect(validator.errors.messages).to include(:version)
      expect(validator.errors.messages[:version]).to eq ["Line 1:Version v1.1 is not supported"]
    end

  end
end

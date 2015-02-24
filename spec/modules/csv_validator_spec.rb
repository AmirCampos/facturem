require 'rails_helper'
require 'csv_validator'

RSpec.describe CSVvalidator, type: :module do
  describe "Validates an imported CSV" do

    before do
      issuer = build(:issuer, tax_id: "B57534125")
      issuer.save
    end

    it "should be a valid CSV file" do
      validator = CSVvalidator::Validator.new("/home/tiago/dev/ironhack/rails/facturem/doc/samples/1.csv")

      p validator.errors.messages unless validator.valid?
      # expect(validator.errors.messages.length).to eq 0
      expect(validator.valid?).to be_truthy
    end

    it "should be a INvalid CSV file" do
      validator = CSVvalidator::Validator.new("/home/tiago/dev/ironhack/rails/facturem/doc/samples/bad.csv")

      expect(validator.valid?).to be_falsy
      # expect(validator.errors.messages).to include(:version)
      expect(validator.errors.messages[:version]).to eq ["Line 1: Version v1.1 is not supported"]
    end

  end
end

# == Schema Information
#
# Table name: invoices
#
#  id            :integer          not null, primary key
#  issuer_id     :integer
#  customer_id   :integer
#  invoice_serie :string           default("")
#  invoice_num   :string
#  invoice_date  :date
#  subject       :string
#  amount        :decimal(11, 2)   default("0")
#  csv           :text
#  xml           :text
#  xsig          :text
#  is_converted  :boolean          default("false")
#  is_signed     :boolean          default("false")
#  is_presented  :boolean          default("false")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe Invoice, type: :model do

  describe "Validations" do
    it "validates is_converted is false" do
      invoice = build(:invoice)

      expect(invoice.valid?).to be true
      expect(invoice.is_converted).to be false
    end

    it "validates is_signed is false" do
      invoice = build(:invoice)

      expect(invoice.valid?).to be true
      expect(invoice.is_signed).to be false
    end

    it "validates is_presented is false" do
      invoice = build(:invoice)

      expect(invoice.valid?).to be true
      expect(invoice.is_presented).to be false
    end
  end

  describe "Relations" do
    it "should have an issuer" do
      invoice = build(:invoice)

      expect(invoice.issuer_id).to be_truthy
    end
    it "should have a customer" do
      invoice = build(:invoice)

      expect(invoice.customer_id).to be_truthy
    end
  end

  describe "Public methods" do

    it "validates invoice_number formatting with invoice_serie" do
      invoice = build(:invoice)

      expect(invoice.invoice_number).to eq "#{invoice.invoice_serie}/#{invoice.invoice_num}"
    end

    it "validates invoice_number formatting with invoice_serie eq to nil" do
      invoice = build(:invoice, invoice_serie: nil)

      expect(invoice.invoice_number).to eq "#{invoice.invoice_num}"
    end

    it "validates invoice_number formatting with invoice_serie blank" do
      invoice = build(:invoice, invoice_serie: "")

      expect(invoice.invoice_number).to eq "#{invoice.invoice_num}"
    end

    it "validates formatted_amount, inner field, should be 0 in creation" do
      invoice = build(:invoice)

      expect(invoice.formatted_amount).to eq "0,00 €"
    end

    it "validates format_currency, param value" do
      expect(Invoice.format_currency(1234.56)).to eq "1.234,56 €"
    end

  end

  describe "Events" do

    before do
      @issuer_B57534125 = build(:issuer, tax_id: "B57534125")
      @issuer_B57534125.save
      @invoice = @issuer_B57534125.invoices.new
      @xml_generator = XMLgenerator::Generator.new
      @invoice.csv = IO.read("#{Rails.root}/spec/fixtures/1.csv")
      @validator = CSVvalidator::Validator.new(@invoice.csv,@xml_generator,@issuer_B57534125)
      @validator.validate
      xml = @xml_generator.generate_xml
      @invoice.customer_id = @xml_generator.header.customer.id
      @invoice.invoice_serie = @xml_generator.header.invoice_serie
      @invoice.invoice_num = @xml_generator.header.invoice_number
      @invoice.invoice_date = @xml_generator.header.invoice_date
      @invoice.subject = @xml_generator.header.invoice_subject
      @invoice.amount = @xml_generator.total.total_invoice
      @invoice.xml = xml

      @invoice.save

      @id = @invoice.id
    end

    it "Validates after_find is_valid_xml" do
      invoice = Invoice.find(@id)

      expect(invoice.is_valid_xml).to be_truthy
    end

    it "Validates after_find has detail" do
      invoice = Invoice.find(@id)

      expect(invoice.detail_list.length).to be > 0
    end
  end
end
     
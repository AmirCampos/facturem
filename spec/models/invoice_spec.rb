require 'rails_helper'

# class Invoice < ActiveRecord::Base
#   has_many :invoice_logs
#   belongs_to :issuers
#   belongs_to :customers

#   validates :invoice_num, presence: true
#   validates :invoice_date, presence: true
#   validates :amount, presence: true, numericality: true

# end

# issuer_id
# customer_id
# invoice_num
# invoice_date
# subject
# amount
# csv
# xml
# xsig
# is_converted
# is_signed
# is_presented

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
end

# == Schema Information
#
# Table name: invoices
#
#  id           :integer          not null, primary key
#  issuer_id    :integer
#  customer_id  :integer
#  invoice_num  :string
#  invoice_date :date
#  subject      :string
#  amount       :decimal(11, 2)   default("0")
#  csv          :text
#  xml          :text
#  xsig         :text
#  is_converted :boolean          default("false")
#  is_signed    :boolean          default("false")
#  is_presented :boolean          default("false")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
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
end

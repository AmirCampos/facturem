# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :string
#  processing_unit    :string
#  accounting_service :string
#  management_unit    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'
  # validates :name, presence: true, length: { in: 4..255 }
  # validates :processing_unit, presence: true, length: { in: 8..10 }
  # validates :accounting_service, presence: true, length: { in: 8..10 }
  # validates :management_unit, presence: true, length: { in: 8..10 }

RSpec.describe Customer, type: :model do
  describe "Validations" do
    it "validates presence of name" do
      customer = build(:customer, name: nil)

      expect(customer.valid?).to be false
      expect(customer.errors[:name].present?).to be true
    end

    it "validates presence of processing_unit" do
      customer = build(:customer, processing_unit: nil)

      expect(customer.valid?).to be false
      expect(customer.errors[:processing_unit].present?).to be true
    end

    it "validates presence of accounting_service" do
      customer = build(:customer, accounting_service: nil)

      expect(customer.valid?).to be false
      expect(customer.errors[:accounting_service].present?).to be true
    end

    it "validates presence of management_unit" do
      customer = build(:customer, management_unit: nil)

      expect(customer.valid?).to be false
      expect(customer.errors[:management_unit].present?).to be true
    end

  end
end

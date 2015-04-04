# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  tax_id             :string
#  name               :string
#  description        :string
#  processing_unit    :string
#  accounting_service :string
#  management_unit    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe Customer, type: :model do

  describe "Validations" do
    it "validates presence of name" do
      customer = build(:customer, name: nil)

      expect(customer.valid?).to be false
      expect(customer.errors[:name].present?).to be true
    end

    # TODO: When gem nivfal updated, test valid administration NIF
    it "validates tax_id" do
      customer = build(:customer, tax_id: "B07559974")

      expect(customer.valid?).to be true
      # valid minitest alternative
      # assert customer.valid?
    end

    it "validates presence of processing_unit" do
      customer = build(:customer, processing_unit: nil)

      expect(customer.valid?).to be false
      expect(customer.errors[:processing_unit].present?).to be true
      # valid minitest alternative
      # assert_includes(customer.errors,:processing_unit)
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

  describe "Public methods" do

    it "validates display_value with no comment" do
      customer = build(:customer)

      expect(customer.display_value).to eq "#{customer.tax_id} #{customer.name}"
    end

    it "validates display_value with description" do
      customer = build(:customer)
      customer.update_attribute :description, "a desc"

      expect(customer.display_value).to eq "#{customer.tax_id} #{customer.name} #{customer.description}"
      # valid minitest alternative
      # assert_equal("#{customer.tax_id} #{customer.name} #{customer.description}",customer.display_value)
    end

  end
end

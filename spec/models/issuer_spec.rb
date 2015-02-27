# == Schema Information
#
# Table name: issuers
#
#  id                  :integer          not null, primary key
#  tax_id              :string
#  company_name        :string           default("")
#  trade_name          :string
#  email               :string
#  password            :string
#  person_type_code    :string           default("J")
#  residence_type_code :string           default("R")
#  address             :string
#  postal_code         :string
#  town                :string
#  province            :string
#  country_code        :string           default("ESP")
#  certificate         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

RSpec.describe Issuer, type: :model do
  describe "Validations" do
    it "validates presence of company_name" do
      issuer = build(:issuer, company_name: nil)

      expect(issuer.valid?).to be false
      expect(issuer.errors[:company_name].present?).to be true
    end

    it "validates presence of email" do
      issuer = build(:issuer, email: nil)

      expect(issuer.valid?).to be false
      expect(issuer.errors[:email].present?).to be true
    end

    it "validates presence of password" do
      issuer = build(:issuer, password: nil)

      expect(issuer.valid?).to be false
      expect(issuer.errors[:password].present?).to be true
    end

    it "validates tax_id is valid" do
      issuer = build(:issuer)

      p issuer.errors.messages unless issuer.valid?
      expect(issuer.valid?).to be true
    end

    # TODO: gem Nifval no contempla ajuntaments. Caldria fer un pull request amb els canvis
    # it "validates P0703200F is valid NIF" do
    #   issuer = build(:issuer, tax_id: "P0703200F")

    #   expect(issuer.valid?).to be true
    # end

    it "validates tax_id is NOT valid" do
      issuer = build(:issuer, tax_id: "123456789")

      expect(issuer.valid?).to be false
    end

    it "validates trade_name is optional" do
      issuer = build(:issuer)

      p issuer.errors.messages unless issuer.valid?
      expect(issuer.valid?).to be true
    end

    it "validates trade_name can not be nil" do
      issuer = build(:issuer, trade_name: nil)

      expect(issuer).to be_invalid
    end

    it "validates country_code is ESP fixed" do
      issuer = build(:issuer)

      expect(issuer.country_code).to eq "ESP"
    end

    it "validates person_type_code is valid" do
      issuer = build(:issuer)

      p issuer.errors.messages unless issuer.valid?
      expect(issuer.valid?).to be true
    end

    it "validates postal_code 00000 is valid" do
      issuer = build(:issuer, postal_code: "00000")

      expect(issuer.valid?).to be true
    end

    it "validates postal_code '7001' is NOT valid" do
      issuer = build(:issuer, postal_code: "7001")

      expect(issuer.valid?).to be false
    end
  end
end

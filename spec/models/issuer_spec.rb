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

      expect(issuer.valid?).to be true
    end

    it "validates tax_id is NOT valid" do
      issuer = build(:issuer, tax_id: "123456789")

      expect(issuer.valid?).to be false
    end
  end
end

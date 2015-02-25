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
#  town                :string
#  province            :string
#  country_code        :string           default("ESP")
#  certificate         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class Issuer < ActiveRecord::Base
  has_many :invoices, :dependent => :delete_all

  validates :tax_id, presence: true, uniqueness: true, nif: true
  validates :company_name, presence: true, length: { in: 4..80}
  validates :trade_name, length: { in: 0..40}
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, presence: true, length: { in: 4..16 }
  validates :person_type_code, presence: true,
    inclusion: { in: %w(F J), message: "%{value} must be 'F' for Individual or 'J' for Legal Entity." }
  validates :residence_type_code, presence: true,
    inclusion: { in: %w(E R U), message: "%{value} must be 'E'-Foreigner; 'R'-Resident in Spain; 'U'Resident in other EU country." }
  validates :address, presence: true, length: {in: 1..80}
  validates :town, presence: true, length: {in: 1..20}
  validates :province, presence: true, length: {in: 1..20}
  validates :country_code, presence: true, length: {is: 3}

end

class Issuer < ActiveRecord::Base
  has_many :invoices, :dependent => :delete_all

  validates :tax_id,
    presence: true,
    uniqueness: true, 
    nif: true
  validates :company_name, presence: true, length: { in: 4..255 }
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i }
  validates :password, presence: true, length: { in: 4..16 }

end

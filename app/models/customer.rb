class Customer < ActiveRecord::Base
  has_many :invoices, :dependent => :delete_all

  validates :name, presence: true, length: { in: 4..255 }
  validates :processing_unit, presence: true, length: { in: 8..10 }
  validates :accounting_service, presence: true, length: { in: 8..10 }
  validates :management_unit, presence: true, length: { in: 8..10 }
end

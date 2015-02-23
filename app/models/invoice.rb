class Invoice < ActiveRecord::Base
  has_many :invoice_logs
  belongs_to :issuer
  belongs_to :customer

  validates :issuer_id, presence: true
  validates :customer_id, presence: true
  validates :invoice_num, presence: true
  validates :invoice_date, presence: true
  validates :amount, presence: true, numericality: true
end

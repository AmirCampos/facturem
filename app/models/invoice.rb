class Invoice < ActiveRecord::Base
  has_many :invoice_logs
  belongs_to :issuer
  belongs_to :customer

  validates :issuer_id, presence: true
  validates :customer_id, presence: true
  validates :invoice_num, presence: true
  validates :invoice_date, presence: true
  validates :amount, presence: true, numericality: true

  after_initialize :on_new_record

  private

  def on_new_record
    self.is_converted = false
    self.is_signed    = false
    self.is_presented = false
  end

end

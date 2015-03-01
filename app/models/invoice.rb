# == Schema Information
#
# Table name: invoices
#
#  id            :integer          not null, primary key
#  issuer_id     :integer
#  customer_id   :integer
#  invoice_serie :string           default("")
#  invoice_num   :string
#  invoice_date  :date
#  subject       :string
#  amount        :decimal(11, 2)   default("0")
#  csv           :text
#  xml           :text
#  xsig          :text
#  is_converted  :boolean          default("false")
#  is_signed     :boolean          default("false")
#  is_presented  :boolean          default("false")
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Invoice < ActiveRecord::Base
  has_many :invoice_logs
  belongs_to :issuer
  belongs_to :customer

  validates :issuer_id, presence: true
  validates :customer_id, presence: true
  validates :invoice_serie, presence: true
  validates :invoice_num, presence: true
  validates :invoice_date, presence: true
  validates :amount, presence: true, numericality: true

  after_save :after_save

  scope :signed, -> { where(is_signed: true) }  
  scope :presented, -> { where(is_presented: true) }  

  def display_value
    # TODO: Format currency amount
    # TODO: testing display_value
    "Customer: #{customer.name}. Subject: #{subject}. Amount: #{amount}"
  end

  def customer_name
    customer.name
  end

  def invoice_number
    # TODO: testing invoice_number
    (invoice_serie == "" ? invoice_num : invoice_serie+"/"+invoice_num)
  end

  private

  def after_save
    if created_at == updated_at # best way of known if INSERT or UPDATE
      invoice_logs.create(
        action: "Issuer imported CSV and saved XML. #{display_value}",
        action_code: InvoiceLog::ACTION_SAVE_INVOICE)
    else
      # TODO: Inform action what changed
      invoice_logs.create(
        action: "Issuer changed invoice. #{display_value}",
        action_code: InvoiceLog::ACTION_INVOICE_SIGNED)
    end
  end
end
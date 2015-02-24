# == Schema Information
#
# Table name: invoices
#
#  id           :integer          not null, primary key
#  issuer_id    :integer
#  customer_id  :integer
#  invoice_num  :string
#  invoice_date :date
#  subject      :string
#  amount       :decimal(11, 2)   default("0")
#  csv          :text
#  xml          :text
#  xsig         :text
#  is_converted :boolean          default("false")
#  is_signed    :boolean          default("false")
#  is_presented :boolean          default("false")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

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

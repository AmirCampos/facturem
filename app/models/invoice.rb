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
require 'csv_validator'
require 'xml_generator'

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
  after_find :after_find

  scope :signed, -> { where(is_signed: true) }
  scope :presented, -> { where(is_presented: true) }

  attr_reader :is_valid_xml
  attr_reader :header
  attr_reader :detail_list
  attr_reader :tax_list
  attr_reader :total
  attr_reader :installment_list

  def display_value
    "Customer: #{customer.name}. Subject: #{subject}. Amount: #{formatted_amount}"
  end

  def customer_name
    customer.name
  end

  def formatted_amount
    (total.nil? ? self.class.format_currency(0) : self.class.format_currency(total.total_invoice))
  end

  def self.format_currency(value)
    ActionController::Base.helpers.number_to_currency(
      value,locale: 'es',unit: "€", separator: ",", delimiter: ".", format: "%n %u")
  end

  def invoice_number
    (invoice_serie.blank? ? invoice_num : invoice_serie+"/"+invoice_num)
  end

  private

  def after_save
    if created_at == updated_at # best way of known it's INSERT, not UPDATE
      invoice_logs.create(
        action: "Issuer imported CSV and saved XML.",
      action_code: InvoiceLog::ACTION_SAVE_INVOICE)
    else
      if is_signed_changed?
        invoice_logs.create(
          action: "Issuer SIGNED invoice.",
        action_code: InvoiceLog::ACTION_INVOICE_SIGNED)
      elsif is_presented_changed?
        invoice_logs.create(
          action: "Issuer PRESENTED invoice.",
        action_code: InvoiceLog::ACTION_INVOICE_PRESENTED)
      else
        invoice_logs.create(
          action: "Issuer changed invoice. Changed fields: #{changed.to_s}",
        action_code: InvoiceLog::ACTION_INVOICE_CHANGED)
      end
    end
  end

  def after_find
    xml_generator = XMLgenerator::Generator.new
    validator = CSVvalidator::Validator.new(csv,xml_generator,self.issuer)
    @is_valid_xml = validator.valid?
    if @is_valid_xml
      @header           = xml_generator.header
      @detail_list      = xml_generator.detail_list
      @tax_list         = xml_generator.tax_list
      @total            = xml_generator.total
      @installment_list = xml_generator.installment_list
    end
  end
end

# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  tax_id             :string
#  name               :string
#  description        :string
#  processing_unit    :string
#  accounting_service :string
#  management_unit    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Customer < ActiveRecord::Base
  has_many :invoices, :dependent => :delete_all

  validates :tax_id, presence: true, uniqueness: true, nif: true
  validates :name, presence: true, length: { in: 4..255 }
  validates :processing_unit, presence: true, length: { in: 8..10 }
  validates :accounting_service, presence: true, length: { in: 8..10 }
  validates :management_unit, presence: true, length: { in: 8..10 }

  def display_value
    # TODO: testing display_value
    result = "#{tax_id} #{name}"
    result = result + " #{description}" unless description == ""
  end
end

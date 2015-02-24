# == Schema Information
#
# Table name: customers
#
#  id                 :integer          not null, primary key
#  name               :string
#  description        :string
#  processing_unit    :string
#  accounting_service :string
#  management_unit    :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

# ToDO: add tax_id to customer

class Customer < ActiveRecord::Base
  has_many :invoices, :dependent => :delete_all

  validates :name, presence: true, length: { in: 4..255 }
  validates :processing_unit, presence: true, length: { in: 8..10 }
  validates :accounting_service, presence: true, length: { in: 8..10 }
  validates :management_unit, presence: true, length: { in: 8..10 }
end

# == Schema Information
#
# Table name: invoice_logs
#
#  id          :integer          not null, primary key
#  invoice_id  :integer
#  action      :string
#  action_code :integer          default("0")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class InvoiceLog < ActiveRecord::Base
  belongs_to :invoices
end

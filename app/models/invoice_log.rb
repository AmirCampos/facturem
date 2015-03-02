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
  ACTION_SAVE_INVOICE      = 0
  ACTION_INVOICE_SIGNED    = 1
  ACTION_INVOICE_PRESENTED = 2
  ACTION_INVOICE_RENDERED  = 3
  ACTION_INVOICE_CHANGED   = 4
  
  belongs_to :invoice

  def display_value
    "#{created_at}: #{action}"
  end
end

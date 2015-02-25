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

# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do
  factory :invoice do
    association :issuer
    association :customer
    invoice_num {Faker::Number.number(10)}
    invoice_date {Date.today}
    amount {Faker::Commerce.price}
  end
end

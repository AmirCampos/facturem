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

# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do
  factory :customer do
    tax_id { 'J07682735'}
    name { Faker::Company.name }
    processing_unit { Faker::Number.number(10).to_s }
    accounting_service { Faker::Number.number(10).to_s }
    management_unit { Faker::Number.number(10).to_s }
  end
end

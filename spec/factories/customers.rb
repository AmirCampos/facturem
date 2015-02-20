# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

# name
# description
# processing_unit
# accounting_service
# management_unit

FactoryGirl.define do
  factory :customer do
    name { Faker::Company.name }
    processing_unit { Faker::Number.number(10).to_s }
    accounting_service { Faker::Number.number(10).to_s }
    management_unit { Faker::Number.number(10).to_s }
  end
end

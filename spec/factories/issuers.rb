# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do
  factory :issuer do
    tax_id { 'B07079999'}
    company_name { Faker::Company.name }
    trade_name { Faker::Company.name } # trade_name is optional
    email    { Faker::Internet.email }
    password { Faker::Internet.password }
    address {Faker::Address.street_address}
    town {Faker::Address.city}
    province {Faker::Address.state}
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

FactoryGirl.define do
  factory :issuer do
    tax_id { 'B07079999'}
    company_name { Faker::Company.name } # Why using lamdba here?
    email    { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end

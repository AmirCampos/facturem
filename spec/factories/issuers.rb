# == Schema Information
#
# Table name: issuers
#
#  id                  :integer          not null, primary key
#  tax_id              :string
#  company_name        :string           default("")
#  trade_name          :string
#  email               :string
#  password            :string
#  person_type_code    :string           default("J")
#  residence_type_code :string           default("R")
#  address             :string
#  town                :string
#  province            :string
#  country_code        :string           default("ESP")
#  certificate         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

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
    town {Faker::Address.city.slice(0,20)}
    province {Faker::Address.state}
  end
end

# Read about factories at https://github.com/thoughtbot/factory_girl

require 'faker'

# issuer_id
# customer_id
# invoice_num
# invoice_date
# subject
# amount
# csv
# xml
# xsig
# is_converted
# is_signed
# is_presented

FactoryGirl.define do
  factory :invoice do
    association :issuer
    association :customer
    # association :issuer, factory: :issuer
    # association :customer, factory: :customer
    invoice_num {Faker::Number.number(10)}
    invoice_date {Date.today}
    amount {Faker::Commerce.price}
  end
end

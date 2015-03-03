# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv_validator'
require 'xml_generator'

def create_issuer(vat_id)
  result = Issuer.find_by(tax_id: vat_id)
  unless result
    result = Issuer.create(
      tax_id: vat_id,
      company_name: Faker::Company.name,
      trade_name: Faker::Company.suffix,
      email: "#{vat_id.downcase}@gmail.com",
      password: "12345",
      address: Faker::Address.street_address,
      postal_code: "07703",
      town: "Maó",
      province: "Balears")
  end
  puts result.errors unless result.valid?
  result
end

def create_invoice(num,issuer)
  csv = IO.read("#{Rails.root}/spec/fixtures/#{num}.csv")
  xml_generator = XMLgenerator::Generator.new
  validator = CSVvalidator::Validator.new(csv,xml_generator)
  validator.validate
  xml = xml_generator.generate_xml

  invoice = issuer.invoices.new
  invoice.customer_id = xml_generator.header.customer.id
  invoice.invoice_serie = xml_generator.header.invoice_serie
  invoice.invoice_num = xml_generator.header.invoice_number
  invoice.invoice_date = xml_generator.header.invoice_date
  invoice.subject = xml_generator.header.invoice_subject
  invoice.amount = xml_generator.total.total_invoice
  invoice.csv = csv
  invoice.xml = xml

  raise "Error creating invoice #{num}: #{invoice.errors.messages.to_a}" unless invoice.valid?

  invoice
end

issuer = create_issuer("B57534125")
create_invoice(1,issuer).save
create_invoice(2,issuer).save
create_invoice(3,issuer).save

issuer = create_issuer("B07079999")
create_invoice(4,issuer).save
create_invoice(5,issuer).save
create_invoice(6,issuer).save

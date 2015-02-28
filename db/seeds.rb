# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'csv_validator'
require 'xml_generator'

  def create_issuer
    Issuer.create(
      tax_id: "B57534125",
      company_name: "MENORCA ZEROS I UNS S.L.",
      trade_name: "SISTEMA",
      email: Faker::Internet.email,
      password: Faker::Internet.password,
      address: "C/Font i Vidal, 5",
      postal_code: "07703",
      town: "Maó",
      province: "Balears")  
  end

  def create_invoice(num)
    file_name = "#{Rails.root}/spec/fixtures/#{num}.csv"
    xml_generator = XMLgenerator::Generator.new
    validator = CSVvalidator::Validator.new(file_name,xml_generator)
    validator.validate
    csv = IO.read(file_name)
    xml = xml_generator.generate_xml

    invoice = @issuer.invoices.new
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

  @issuer = create_issuer
  create_invoice(1).save
  create_invoice(2).save
  create_invoice(3).save

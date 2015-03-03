require 'rails_helper'
require 'csv_validator'
require 'faker'
require "awesome_print"

def build_issuer
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

RSpec.describe XMLgenerator, type: :module do

  describe "Validates XMLgenerator with 3.csv" do

    before do
      @issuer = build_issuer
      @raw_csv_3 = IO.read("#{Rails.root}/spec/fixtures/3.csv")

      @xml_generator = XMLgenerator::Generator.new
      @validator = CSVvalidator::Validator.new(@raw_csv_3,@xml_generator,@issuer)
      @validator.validate
    end

    it "sholud be a valid issuer" do
      p @issuer.errors.messages unless @issuer.valid?
      expect(@issuer.valid?).to be_truthy
    end

    it "sholud be a valid validator" do
      p @validator.errors.messages unless @validator.valid?
      expect(@validator.valid?).to be_truthy
    end

    it "XML should have customer address" do
      expect(@xml_generator.header.customer_address).to eq "Plaza des Jaleo, 3"
    end
    
    it "XML should have n detail.lines" do
      expect(@xml_generator.detail_list.size).to eq 2
    end

    it "XML should have n installment_list.lines" do
      expect(@xml_generator.installment_list.size).to eq 3
    end

    it "XML should have have this total amount" do
      expect(@xml_generator.total.total_invoice).to eq "2553.24"
    end

    it "XML should have have this total amount" do
      File.open("#{Rails.root}/spec/fixtures/3.xml", 'w') { |file| file.write(@xml_generator.generate_xml) }
      # puts @xml_generator.generate_xml
      # expect(@xml_generator.generate_xml).to eq "adsbas"
    end

    it "total_amount_before_taxes should be total_gross_amount - total_general_discount" do
    # El fichero seleccionado no es validable: 
    # Error en su lectura: 
    # TotalImporteBrutoAntesImpuestos de la factura n�mero 2 no es igual a 
    # TotalImporteBruto - TotalDescuentosGenerales + TotalCargosGenerales, deber�a ser :2121.12    

      expect(@xml_generator.total.total_amount_before_taxes.to_f).to be ==
        (@xml_generator.total.total_gross_amount.to_f - @xml_generator.total.total_general_discount.to_f)
    end

  end
  describe "Validates XMLgenerator with 2.csv" do

    before do
      @issuer = build_issuer
      @raw_csv_2 = IO.read("#{Rails.root}/spec/fixtures/2.csv")

      @xml_generator = XMLgenerator::Generator.new
      @validator = CSVvalidator::Validator.new(@raw_csv_2,@xml_generator,@issuer)
      @validator.validate
    end

    it "sholud be a valid issuer" do
      p @issuer.errors.messages unless @issuer.valid?
      expect(@issuer.valid?).to be_truthy
    end

    it "sholud be a valid validator" do
      p @validator.errors.messages unless @validator.valid?
      expect(@validator.valid?).to be_truthy
    end

    it "XML should have customer address" do
      expect(@xml_generator.header.customer_address).to eq "Plaza Constitución, 1"
    end
    
    it "XML should have n detail.lines" do
      expect(@xml_generator.detail_list.size).to eq 2
    end

    it "XML should have n installment_list.lines" do
      expect(@xml_generator.installment_list.size).to eq 1
    end

    it "XML should have have this total DISCOUNT amount" do
      expect(@xml_generator.total.total_general_discount).to eq "161.475"
    end

    it "XML should have have this total amount" do
      File.open("#{Rails.root}/spec/fixtures/2.xml", 'w') { |file| file.write(@xml_generator.generate_xml) }
    end

  end
  describe "Validates XMLgenerator with 1.csv" do

    before do
      @issuer = build_issuer
      @raw_csv_1 = IO.read("#{Rails.root}/spec/fixtures/1.csv")

      @xml_generator = XMLgenerator::Generator.new
      @validator = CSVvalidator::Validator.new(@raw_csv_1,@xml_generator,@issuer)
      @validator.validate
    end

    it "sholud be a valid issuer" do
      p @issuer.errors.messages unless @issuer.valid?
      expect(@issuer.valid?).to be_truthy
    end

    it "sholud be a valid validator" do
      p @validator.errors.messages unless @validator.valid?
      expect(@validator.valid?).to be_truthy
    end

    it "XML should have customer address" do
      expect(@xml_generator.header.customer_address).to eq "Plaza des Jaleo, 3"
    end
    
    it "XML should have n detail.lines" do
      expect(@xml_generator.detail_list.size).to eq 1
    end

    it "XML should have NOT installment_list.lines" do
      expect(@xml_generator.installment_list.size).to eq 0
    end

    it "XML should have have this total amount" do
      expect(@xml_generator.total.total_invoice).to eq "1210"
    end

    it "XML should have have this total amount" do
      File.open("#{Rails.root}/spec/fixtures/1.xml", 'w') { |file| file.write(@xml_generator.generate_xml) }
    end

  end
end

class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :issuer_id
      t.integer :customer_id
      t.string :invoice_num
      t.date :invoice_date
      t.string :subject
      t.decimal :amount, precision: 11, scale: 2, default: 0
      t.text :csv
      t.text :xml
      t.text :xsig
      t.boolean :is_converted, default: false
      t.boolean :is_signed, default: false
      t.boolean :is_presented, default: false

      t.timestamps null: false
    end
    add_index :invoices, :issuer_id
    add_index :invoices, [:issuer_id, :customer_id, :id]
    add_index :invoices, [:issuer_id, :invoice_num, :id]
    add_index :invoices, [:issuer_id, :invoice_date, :id]
  end
end

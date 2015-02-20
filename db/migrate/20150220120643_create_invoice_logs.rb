class CreateInvoiceLogs < ActiveRecord::Migration
  def change
    create_table :invoice_logs do |t|
      t.integer :invoice_id
      t.string :action
      t.integer :action_code, :default 0

      t.timestamps null: false
    end
    add_index :invoice_logs, :invoice_id
  end
end

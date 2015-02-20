class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :name
      t.string :description
      t.string :processing_unit
      t.string :accounting_service
      t.string :management_unit

      t.timestamps null: false
    end
  end
end

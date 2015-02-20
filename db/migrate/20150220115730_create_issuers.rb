class CreateIssuers < ActiveRecord::Migration
  def change
    create_table :issuers do |t|
      t.string :vat_id
      t.string :company_name
      t.text :certificate
      t.string :email
      t.string :password

      t.timestamps null: false
    end
    add_index :issuers, :vat_id, unique: true
  end
end

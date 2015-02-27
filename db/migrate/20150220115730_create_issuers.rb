class CreateIssuers < ActiveRecord::Migration
  def change
    create_table :issuers do |t|
      t.string :tax_id
      t.string :company_name, default: ""
      t.string :trade_name
      t.string :email
      t.string :password

      t.string :person_type_code, default: "J" #[F], [J]
      t.string :residence_type_code, default: "R" #[E], [R], [U]
      t.string :address
      t.string :postal_code
      t.string :town
      t.string :province
      t.string :country_code, default: "ESP"

      t.text :certificate

      t.timestamps null: false
    end
    add_index :issuers, :tax_id, unique: true
  end
end

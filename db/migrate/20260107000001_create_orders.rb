class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :order_number, null: false
      t.decimal :total_amount, precision: 10, scale: 2, null: false
      t.string :status, default: 'pending', null: false
      t.string :stripe_payment_intent_id
      t.string :shipping_name, null: false
      t.text :shipping_address, null: false
      t.string :shipping_city, null: false
      t.string :shipping_state
      t.string :shipping_zip, null: false
      t.string :shipping_country, default: 'India', null: false
      t.string :email, null: false
      t.string :phone

      t.timestamps
    end

    add_index :orders, :order_number, unique: true
    add_index :orders, :stripe_payment_intent_id
    add_index :orders, :status
  end
end

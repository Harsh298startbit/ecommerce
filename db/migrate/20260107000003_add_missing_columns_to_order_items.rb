class AddMissingColumnsToOrderItems < ActiveRecord::Migration[6.1]
  def change
    add_reference :order_items, :product, foreign_key: true
    add_column :order_items, :product_name, :string
    add_column :order_items, :variant_name, :string
  end
end

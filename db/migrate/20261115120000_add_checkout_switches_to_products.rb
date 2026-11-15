class AddCheckoutSwitchesToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :ask_checkout_source, :boolean, default: true, null: false
    add_column :products, :managed_payments, :boolean, default: true, null: false
  end
end

class AddAutomaticTaxToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :automatic_tax, :boolean, default: false, null: false
  end
end

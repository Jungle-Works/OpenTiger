class AddCheckoutFieldPriceToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :checkout_field_price_cents, :integer, :default => 0
  end
end

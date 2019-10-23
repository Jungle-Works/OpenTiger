class AddColumnToTransaction < ActiveRecord::Migration[5.1]
  def change
    add_column :transactions, :additional_info, :json
    add_column :transactions, :additional_price, :float
  end
end

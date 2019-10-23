class AddCheckoutFlowToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :checkout_flow, :integer, default: 0
  end
end

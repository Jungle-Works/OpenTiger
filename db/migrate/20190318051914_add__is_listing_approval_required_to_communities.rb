class AddIsListingApprovalRequiredToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :IsListingApprovalRequired, :boolean
  end
end

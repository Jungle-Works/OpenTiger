class AddIsApprovedToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :is_approved, :integer
  end
end

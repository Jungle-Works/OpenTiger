class AddUserIdToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :user_id, :string
  end
end

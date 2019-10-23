class AddFieldsForAppVersionManagementToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :current_version_ios, :string, default: ""
    add_column :communities, :current_version_android, :string, default: ""
    add_column :communities, :current_version_message, :string, default: ""
    add_column :communities, :force_update_version_ios, :string, default: ""
    add_column :communities, :force_update_version_android, :string, default: ""
    add_column :communities, :force_update_version_message, :string, default: ""
  end
end

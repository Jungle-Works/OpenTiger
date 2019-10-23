class AddFieldsForAppVersionLinksToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :android_store_link, :text
    add_column :communities, :ios_store_link, :text
  end
end

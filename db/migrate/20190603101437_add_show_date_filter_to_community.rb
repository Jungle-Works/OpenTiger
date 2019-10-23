class AddShowDateFilterToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :show_date_filter, :boolean, default: false
  end
end

class AddIsActiveToContentPages < ActiveRecord::Migration[5.1]
  def change
    add_column :content_pages, :is_active, :boolean, :default => true
    #Ex:- :default =>''
  end
end

class CreateContentPages < ActiveRecord::Migration[5.1]
  def change
    create_table :content_pages do |t|
      t.string :title
      t.text :data ,limit: 16.megabytes - 1, null: false
      t.string :end_point
      t.integer :community_id
      t.boolean :is_deleted, :default => false
  
      t.timestamps
    end
  end
end

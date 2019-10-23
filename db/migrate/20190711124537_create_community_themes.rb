class CreateCommunityThemes < ActiveRecord::Migration[5.1]
  def change
    create_table :community_themes do |t|
      t.integer :community_id, null: false
      t.integer :theme_id, null: false
      t.text :content, limit: 16.megabytes - 1, null: false
      t.boolean :enabled, default: false
      t.datetime :released_at

      t.timestamps
    end
    add_index :community_themes, :community_id
    add_index :community_themes, :theme_id
  end
end

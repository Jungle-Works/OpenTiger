class CreateTbActiveAppSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :tb_active_app_sessions do |t|
      t.string       :person_id
      t.integer      :community_id
      t.string       :session_token, null: false
      t.string       :device_token
      t.string       :device_type
      t.datetime     :refreshed_at, null: false
      t.timestamps
    end
    add_index :tb_active_app_sessions, :person_id
    add_index :tb_active_app_sessions, :session_token, unique: true
  end
end

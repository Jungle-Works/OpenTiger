class AddCommunityIdToRailsPushNotificationsApnsApps < ActiveRecord::Migration[5.1]
  def change
    add_column :rails_push_notifications_apns_apps, :community_id, :integer
  end
end

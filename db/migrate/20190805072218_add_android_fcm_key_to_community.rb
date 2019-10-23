class AddAndroidFcmKeyToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :android_fcm_key, :string, default: ""
  end
end

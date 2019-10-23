class AddAppSecretKeyToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :app_secret_key, :text
  end
end

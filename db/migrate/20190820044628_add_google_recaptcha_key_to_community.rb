class AddGoogleRecaptchaKeyToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :google_recaptcha_key, :string, default: ""
  end
end

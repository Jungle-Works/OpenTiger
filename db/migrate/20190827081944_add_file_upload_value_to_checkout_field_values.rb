class AddFileUploadValueToCheckoutFieldValues < ActiveRecord::Migration[5.1]
  def change
    add_column :custom_field_values, :file_upload_value, :text
  end
end

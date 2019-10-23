class CreateHippoApiLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :hippo_api_logs do |t|
      t.string :action
      t.string :email
      t.text :api_response

      t.timestamps
    end
  end
end

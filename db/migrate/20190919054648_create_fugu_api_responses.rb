class CreateFuguApiResponses < ActiveRecord::Migration[5.1]
  def change
    create_table :fugu_api_responses do |t|
      t.string :action
      t.integer :transaction_id
      t.text :api_response

      t.timestamps
    end
  end
end

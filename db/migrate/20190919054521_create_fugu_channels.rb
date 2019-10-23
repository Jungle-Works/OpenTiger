class CreateFuguChannels < ActiveRecord::Migration[5.1]
  def change
    create_table :fugu_channels do |t|
      t.string :channel_id
      t.integer :transaction_id
      t.string :seller
      t.string :buyer
      t.string :workspace_id

      t.timestamps
    end
  end
end

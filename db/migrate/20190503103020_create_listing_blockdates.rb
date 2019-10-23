class CreateListingBlockdates < ActiveRecord::Migration[5.1]
  def change
    create_table :listing_blockdates do |t|
      t.string :listing_id
      t.date :date

      t.timestamps
    end
  end
end

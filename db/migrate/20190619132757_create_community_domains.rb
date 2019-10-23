class CreateCommunityDomains < ActiveRecord::Migration[5.1]
  def change
    create_table :community_domains do |t|
      t.integer :community_id
      t.string :custom_domain
      t.string :previous_domain
      t.integer :in_processing, default: 0
      #Ex:- :default =>''

      t.timestamps
    end
  end
end

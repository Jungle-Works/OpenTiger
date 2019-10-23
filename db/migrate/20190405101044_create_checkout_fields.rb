class CreateCheckoutFields < ActiveRecord::Migration[5.1]
  def change
    create_table :checkout_fields do |t|
      t.string   :people_id, null: false
      t.integer  :community_id, null: false
      t.integer  :sort_priority
      t.string   :field_type
      t.string   :title
      t.string   :value
      t.string   :locale
      t.boolean  :is_required, :default =>1
      t.string   :entity_type
      t.float    :min
      t.float    :max
      t.boolean  :is_deleted, :default =>0
      t.timestamps
    end
    add_index :checkout_fields, :people_id
    add_index :checkout_fields, :community_id
  end
end

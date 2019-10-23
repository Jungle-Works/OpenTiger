class CreateTookanTasks < ActiveRecord::Migration[5.1]
  def change
    create_table :tookan_tasks do |t|
      t.integer :listing_id
      t.integer :transaction_id
      t.string :buyer_id
      t.string :seller_id
      t.string :tookan_job_id
      t.string :tookan_pickup_id
      t.string :tookan_delivery_id
      t.text :job_pickup_address
      t.text :job_delivery_address
      t.float :task_delivery_charges
      t.string :tookan_api_user_id
      t.float :job_delivery_latitude
      t.float :job_delivery_longitude
      t.float :job_pickup_latitude
      t.float :job_pickup_longitude
      t.boolean :pickup_required
      t.boolean :delivery_required

      t.timestamps
    end
  end
end

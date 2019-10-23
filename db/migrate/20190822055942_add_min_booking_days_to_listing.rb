class AddMinBookingDaysToListing < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :min_booking_days, :integer, default: 1
  end
end


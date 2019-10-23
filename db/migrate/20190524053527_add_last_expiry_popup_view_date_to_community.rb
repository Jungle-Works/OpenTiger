class AddLastExpiryPopupViewDateToCommunity < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :last_expiry_popup_view_date, :date
  end
end

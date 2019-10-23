object false
node(:message){"Action Complete"}
node(:status){200}

child @transaction, :root => "data", :object_root => false do

    attributes :listing_id,:community_id,:updated_at,:unit_type, :commission_price, :payment_process, :payment_gateway, :shipping_price_cents, :current_state, :delivery_method
    attributes :listing_quantity => "quantity"
    attributes :listing_title => "title"
    attributes :unit_price_currency => "currency"
    attributes :unit_price_cents => "price_cents"
    node(:pickup_enabled) { |t| t.listing.pickup_enabled }
    node(:shipping_enabled) { |t| t.listing.try(:listing_shape).try(:shipping_enabled) }
    node(:tookan_delivery_charge) { @deliver_cHarge  }
    node(:person) { |c| c.listing_owner }
    node(:other_party) { |c| c.other_party_app(@person) }
    node(:price_enabled){  |c| c.price_enabled }
    node(:conversation_statuses){  |c| c.get_conversation_statuses(@person) }
    node(:conversation_btns){  |c| c.get_conversation_btns(@person) }
    child :all_listing_images, :root => "listing_images", :object_root => false do
        attributes :id, :position
        attributes :get_original_image_url => "get_image_url"
    end
    child :shipping_address, :object_root => false do
        attributes :name, :phone, :postal_code, :city, :country, :state_or_province, :street1, :street2, :country_code, :status
    end
    child :transaction_checkout_fields, :object_root => false do
        attributes :id, :field_type, :title, :value
        child :transaction_checkout_field_selections, :object_root => false do
            attributes :id, :label, :description, :value
        end

    end
    child :booking, :object_root => false do
        attributes :id, :start_time, :end_time, :per_hour, :start_on, :end_on
        node(:start_time_hour) {|b| b.start_time.present? ? b.start_time.hour : 0}
        node(:end_time_hour) {|b| b.end_time_hour}
    end




end
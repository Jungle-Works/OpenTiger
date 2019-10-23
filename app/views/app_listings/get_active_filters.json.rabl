object false
node(:message){"Action Complete"}
node(:status){200}
child @current_community, :root => "data", :object_root => false do
    attributes :show_price_filter, :price_filter_min, :price_filter_max
    node(:minimum_price_cents) {  |c| c.pay_settings.last.minimum_price_cents }
    child :categories, :object_root => false do
        attributes :id, :parent_id
        node(:name) {  |c| c.display_name }
        node(:listing_custom_fields) {  |c| c.get_active_filter_detail }
        child :active_listing_shapes, :root => "listing_shapes", :object_root => false do
            attributes :id,:price_enabled,:shipping_enabled
            node(:name) { |d| d.display_name.translation }
            node(:action_button) { |d| d.display_action_button_name.translation }
            node(:allow_online_payments) { |d| d.try(:transaction_process).try(:allow_seller_to_accept_payment) }
            child :listing_units, :object_root => false do
                attributes :id, :unit_type, :quantity_selector, :kind
                node(:translation) {  |c| c.get_name  }
            end
        end
    end
end
object false
node(:message){"Action Complete"}
node(:status){200}
if @listing_data.present?
    child @listing_data, :root=> "data", :object_root => false do
        attributes :id => "listing_id"
        attributes :author_id, :community_id, :title ,:times_viewed ,:language ,:sort_date ,:description, :origin ,:destination , :valid_until ,:share_type_id ,:listing_shape_id ,:transaction_process_id ,:currency ,:quantity ,:unit_type ,:price_enabled ,:shipping_enabled ,:name ,:sort_priority ,:unit_type ,:quantity_selector, :kind, :require_shipping_address, :pickup_enabled, :per_hour_ready, :min_booking_days
        attributes :cal_star_rating => "list_avg_rating"
        node(:price_cents){ |a| a.showprice }
        node(:action_button){|a| a.actionButton }
        node(:payment_process) { |a| a.getProcess }
        node(:listing_block_and_booked_dates) { |a| a.app_fetch_all_booked_and_block_dates }
        node(:review_count){|a| a.count_comment}
        node(:price_enabled){|a| a.listing_shape.price_enabled}
        node(:shipping_enabled){|a| a.listing_shape.shipping_enabled}
        node(:allow_online_payments){|a| a.listing_shape.try(:transaction_process).try(:allow_seller_to_accept_payment)}
        node(:shipping_price_cents){|a| a.shipping_price_cents}
        node(:shipping_price_additional_cents){|a| a.shipping_price_additional_cents}
        node(:stripe_in_use){|a| a.author.stripe_in_use(a.community_id)}
        node(:paypal_in_use){|a| a.author.paypal_in_use(a.community_id)}
        child :listing_images, :object_root => false do
            attributes :id, :position
            attributes :get_original_image_url => "get_image_url"
        end
        child :working_time_slots, :object_root => false do
            attributes :id, :week_day, :from, :till
            node(:num_from){|s| s.from.to_i}
            node(:num_till){|s| s.till.to_i}
        end
        child :bookings_per_hour, :root => "bookings", :object_root => false do
            attributes :id, :start_time, :end_time, :per_hour, :start_on, :end_on
            node(:start_time_hour) {|b| b.start_time.present? ? b.start_time.hour : 0}
            node(:end_time_hour) {|b| b.end_time_hour}
        end
        child :location, :object_root => false do
            attributes :id, :latitude, :longitude, :address, :google_address
        end
        child :author, :object_root => false do
            attributes :id, :given_name, :family_name, :image_url, :displayed_name
        end
        child :comments, :object_root => false do
            attributes :id, :content, :updated_at
            child :author, :object_root => false do
                attribute :id, :given_name, :image_url, :displayed_name
            end
        end        
        child :custom_field_values, :object_root => false do
            attributes :id, :type, :text_value, :numeric_value, :selected_option_ids, :'date_value(1i)', :'date_value(2i)', :'date_value(3i)'
            child :question, :object_root => false do
                attributes :id, :names        
            end
        end
        child :custom_field_values, :object_root => false do
            attributes :type, :cname, :final_value
        end 
        child :get_listing_review, :root => "listing_review", :object_root => false do
            attributes :id => "review" 
            attributes :starter_id => "reciever_id"
        end
    end
else
    node(:data){{}}
end
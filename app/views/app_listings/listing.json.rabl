object false
node(:message){"Action Complete"}
node(:status){200}
if @listing_data.present?
    child @listing_data, :root=> "data", :object_root => false do
        attributes :id => "listing_id"
        attributes :author_id, :community_id, :title ,:times_viewed ,:language ,:sort_date ,:description, :origin ,:destination , :valid_until ,:share_type_id ,:listing_shape_id ,:transaction_process_id ,:currency ,:quantity ,:unit_type, :name ,:sort_priority ,:unit_type ,:quantity_selector, :kind
        attributes :cal_star_rating => "list_avg_rating"
        node(:price_cents){ |a| a.showprice }
        node(:action_button){|a| a.actionButton }
        node(:payment_process) { |a| a.getProcess }
        node(:listing_block_and_booked_dates) { |a| a.app_fetch_all_booked_and_block_dates }
        node(:review_count){|a| a.count_comment}
        node(:price_enabled){|a| a.try(:listing_shape).try(:price_enabled)}
        node(:shipping_enabled){|a| a.listing_shape.shipping_enabled}
        node(:allow_online_payments){|a| a.listing_shape.try(:transaction_process).try(:allow_seller_to_accept_payment)}
        node(:shipping_price_cents){|a| a.shipping_price_cents}
        node(:shipping_price_additional_cents){|a| a.shipping_price_additional_cents}
        child :listing_images, :object_root => false do
            attributes :id, :position
            attributes :get_medium_image_url => "get_image_url"
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
        child :get_listing_review, :root => "listing_review", :object_root => false do
            attributes :id => "review"
            attributes :starter_id => "reciever_id"
        end
    end
else
    node(:data){{}}
end
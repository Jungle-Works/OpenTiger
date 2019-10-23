object false
node(:message){"Action Complete"}
node(:status){200}
child @listing_data, :root => "data", :object_root => false do

attributes :author_id, :community_id, :title ,:times_viewed ,:language ,:sort_date ,:description, :origin ,:destination , :valid_until ,:share_type_id ,:listing_shape_id ,:transaction_process_id ,:currency ,:quantity ,:unit_type ,:price_enabled ,:shipping_enabled ,:name ,:sort_priority ,:unit_type ,:quantity_selector,:kind
attributes :id => "listing_id"
node(:price_cents){ |a| a.showprice }
attributes :cal_star_rating => "list_avg_rating"
child :listing_images, :object_root => false do
    attributes :id, :position
    attributes :get_medium_image_url => "get_image_url"
end
node(:review_count){|a| a.count_comment}
child :location, :object_root => false do
    attributes :id, :latitude, :longitude, :address, :google_address
end

end
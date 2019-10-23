object false
node(:message){"Action Complete"}
node(:status){200}

child @community, :root => "data", :object_root => false do

    attributes :ident,:settings, :app_secret_key, :user_id, :google_maps_key, :currency, :country, :currency_symbol, :default_browse_view, :listing_comments_in_use, :facebook_connect_enabled, :facebook_connect_id, :facebook_connect_secret, :google_analytics_key, :google_maps_key, :transaction_agreement_in_use, :domain
    
    child :configuration, :object_root => false do 

        attributes :distance_unit, :limit_search_distance 


    end

    child :community_customizations, :object_root => false do
       attributes :locale, :name, :transaction_agreement_label, :transaction_agreement_content, :search_placeholder
    end
    child :checkout_fields, :object_root => false do
       attributes :sort_priority, :field_type, :title, :value, :locale, :is_required, :entity_type, :min, :max, :is_deleted, :checkout_field_options
    end

    node(:person_custom_field) {  |c| c.get_active_filter_detail }
    node(:post_new_listing_button) { |c| c.get_post_listing_name }
    node(:google_map_key_details) { |c| c.google_map_key_details }
    node(:app_version_status) { @app_version_message_and_status[:status] }
    node(:app_version_message) { @app_version_message_and_status[:message] }
    node(:store_link) { @app_version_message_and_status[:store_link] }
    node(:file_upload_config) { @s3_signup_fields }
end

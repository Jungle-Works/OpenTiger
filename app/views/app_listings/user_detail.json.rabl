object false
node(:message){"Action Complete"}
node(:status){200}

child @current_user, :root => "data", :object_root => false do
    attributes :is_admin, :locale, :preferences, :active_days_count, :username, :sign_in_count, :given_name, :family_name, :display_name, :phone_number, :facebook_id, :authentication_token, :deal_id, :community_id, :displayed_name, :is_posting_allowed
    attributes :id => "person_id"
    node(:allowed_emails){ @current_community.allowed_emails }
    node(:country){ @current_community.country }
    node(:ident){ @current_community.ident }
    node(:domain){ @current_community.domain }
    node(:use_domain){ @current_community.use_domain }
    node(:settings){ @current_community.settings }
    node(:slogan){ @current_community.slogan }
    node(:email){ @current_user.try(:emails).try(:last).try(:address) }
    node(:notification_count){ @notification_count }
    node(:session_token){ @token }
    node(:has_signup){ @has_signup }
    node(:membership_status){ @current_user.community_membership.status }
end
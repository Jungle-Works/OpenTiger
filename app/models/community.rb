# == Schema Information
#
# Table name: communities
#
#  id                                         :integer          not null, primary key
#  uuid                                       :binary(16)       not null
#  ident                                      :string(255)
#  domain                                     :string(255)
#  use_domain                                 :boolean          default(FALSE), not null
#  created_at                                 :datetime
#  updated_at                                 :datetime
#  settings                                   :text(65535)
#  consent                                    :string(255)
#  transaction_agreement_in_use               :boolean          default(FALSE)
#  email_admins_about_new_members             :boolean          default(FALSE)
#  use_fb_like                                :boolean          default(FALSE)
#  real_name_required                         :boolean          default(TRUE)
#  automatic_newsletters                      :boolean          default(TRUE)
#  join_with_invite_only                      :boolean          default(FALSE)
#  allowed_emails                             :text(16777215)
#  users_can_invite_new_users                 :boolean          default(TRUE)
#  private                                    :boolean          default(FALSE)
#  label                                      :string(255)
#  show_date_in_listings_list                 :boolean          default(FALSE)
#  all_users_can_add_news                     :boolean          default(TRUE)
#  custom_frontpage_sidebar                   :boolean          default(FALSE)
#  event_feed_enabled                         :boolean          default(TRUE)
#  slogan                                     :string(255)
#  description                                :text(65535)
#  country                                    :string(255)
#  members_count                              :integer          default(0)
#  user_limit                                 :integer
#  monthly_price_in_euros                     :float(24)
#  logo_file_name                             :string(255)
#  logo_content_type                          :string(255)
#  logo_file_size                             :integer
#  logo_updated_at                            :datetime
#  cover_photo_file_name                      :string(255)
#  cover_photo_content_type                   :string(255)
#  cover_photo_file_size                      :integer
#  cover_photo_updated_at                     :datetime
#  small_cover_photo_file_name                :string(255)
#  small_cover_photo_content_type             :string(255)
#  small_cover_photo_file_size                :integer
#  small_cover_photo_updated_at               :datetime
#  custom_color1                              :string(255)
#  custom_color2                              :string(255)
#  slogan_color                               :string(6)
#  description_color                          :string(6)
#  stylesheet_url                             :string(255)
#  stylesheet_needs_recompile                 :boolean          default(FALSE)
#  service_logo_style                         :string(255)      default("full-logo")
#  currency                                   :string(3)        not null
#  facebook_connect_enabled                   :boolean          default(TRUE)
#  minimum_price_cents                        :integer
#  hide_expiration_date                       :boolean          default(TRUE)
#  facebook_connect_id                        :string(255)
#  facebook_connect_secret                    :string(255)
#  google_analytics_key                       :string(255)
#  google_maps_key                            :string(64)
#  name_display_type                          :string(255)      default("first_name_with_initial")
#  twitter_handle                             :string(255)
#  use_community_location_as_default          :boolean          default(FALSE)
#  preproduction_stylesheet_url               :string(255)
#  show_category_in_listing_list              :boolean          default(FALSE)
#  default_browse_view                        :string(255)      default("grid")
#  wide_logo_file_name                        :string(255)
#  wide_logo_content_type                     :string(255)
#  wide_logo_file_size                        :integer
#  wide_logo_updated_at                       :datetime
#  listing_comments_in_use                    :boolean          default(FALSE)
#  show_listing_publishing_date               :boolean          default(FALSE)
#  require_verification_to_post_listings      :boolean          default(FALSE)
#  show_price_filter                          :boolean          default(FALSE)
#  price_filter_min                           :integer          default(0)
#  price_filter_max                           :integer          default(100000)
#  automatic_confirmation_after_days          :integer          default(14)
#  favicon_file_name                          :string(255)
#  favicon_content_type                       :string(255)
#  favicon_file_size                          :integer
#  favicon_updated_at                         :datetime
#  default_min_days_between_community_updates :integer          default(7)
#  listing_location_required                  :boolean          default(FALSE)
#  custom_head_script                         :text(65535)
#  follow_in_use                              :boolean          default(TRUE), not null
#  logo_processing                            :boolean
#  wide_logo_processing                       :boolean
#  cover_photo_processing                     :boolean
#  small_cover_photo_processing               :boolean
#  favicon_processing                         :boolean
#  deleted                                    :boolean
#  end_user_analytics                         :boolean          default(TRUE)
#  show_slogan                                :boolean          default(TRUE)
#  show_description                           :boolean          default(TRUE)
#  hsts_max_age                               :integer
#  footer_theme                               :integer          default("dark")
#  footer_copyright                           :text(65535)
#  footer_enabled                             :boolean          default(FALSE)
#  logo_link                                  :string(255)
#  user_id                                    :string(255)
#  IsListingApprovalRequired                  :boolean          default(FALSE)
#  app_secret_key                             :text(65535)
#  last_expiry_popup_view_date                :date
#  pre_approved_listings                      :boolean          default(FALSE)
#  show_date_filter                           :boolean          default(FALSE)
#  rental_vertical                            :string(255)
#  checkout_flow                              :integer          default(1)
#  android_fcm_key                            :string(255)      default("")
#  google_connect_enabled                     :boolean
#  google_connect_id                          :string(255)
#  google_connect_secret                      :string(255)
#  linkedin_connect_enabled                   :boolean
#  linkedin_connect_id                        :string(255)
#  linkedin_connect_secret                    :string(255)
#  google_recaptcha_key                       :string(255)      default("")
#  allow_free_conversations                   :boolean          default(TRUE)
#
# Indexes
#
#  index_communities_on_domain  (domain)
#  index_communities_on_ident   (ident)
#  index_communities_on_uuid    (uuid) UNIQUE
#

class Community < ApplicationRecord

  require 'compass'
  require 'sass/plugin'

  include ApplicationHelper
  include EmailHelper

  has_many :community_memberships, :dependent => :destroy
  has_many :members, -> { merge(CommunityMembership.accepted) }, :through => :community_memberships, :source => :person
  has_many :admins, -> { merge(CommunityMembership.admin.not_banned) }, :through => :community_memberships, :source => :person
  has_many :members_all_statuses, :through => :community_memberships, :source => :person
  has_many :invitations, :dependent => :destroy
  has_one :location, :dependent => :destroy
  has_many :community_customizations, :dependent => :destroy
  has_many :menu_links, -> { for_topbar.sorted }, :dependent => :destroy
  has_many :footer_menu_links, -> { for_footer.sorted }, :class_name => "MenuLink",  :dependent => :destroy
  has_many  :content_pages
  attr_accessor :currency_symbol
  has_many :categories, -> { order("sort_priority") }
  has_many :top_level_categories, -> { where("parent_id IS NULL").order("sort_priority") }, :class_name => "Category"
  has_many :subcategories, -> { where("parent_id IS NOT NULL").order("sort_priority") }, :class_name => "Category"

  has_many :people
  has_many :conversations
  has_many :transactions

  has_many :listings
  has_many :listing_shapes
  has_many :shapes, ->{ exist_ordered }, class_name: 'ListingShape'

  has_many :transaction_processes

  has_one :paypal_account # Admin paypal account

  has_many :custom_fields, -> { for_listing },  :dependent => :destroy
  has_many :custom_dropdown_fields, -> { for_listing.dropdown }, :class_name => "CustomField", :dependent => :destroy
  has_many :custom_numeric_fields, -> { for_listing.numeric }, :class_name => "NumericField", :dependent => :destroy
  has_many :person_custom_fields, -> { for_person.sorted }, :class_name => "CustomField",  :dependent => :destroy
  has_many :person_custom_dropdown_fields, -> { for_person.sorted.dropdown }, :class_name => "CustomField", :dependent => :destroy
  has_many :person_custom_numeric_fields, -> { for_person.sorted.numeric }, :class_name => "NumericField", :dependent => :destroy
  has_many :marketplace_sender_emails

  has_one :configuration, class_name: 'MarketplaceConfigurations'
  has_one :social_logo, :dependent => :destroy
  has_many :social_links, -> { sorted }, :dependent => :destroy
  has_many :people
  has_many :emails
  has_many :community_domains
  has_many :community_themes
  has_many :tb_active_app_sessions, :dependent => :destroy
  has_many :transaction_checkout_fields 
  has_many :transaction_checkout_field_selections
  
  has_many :checkout_fields
  has_many :pay_settings, :class_name => "PaymentSettings"

  accepts_nested_attributes_for :social_logo
  accepts_nested_attributes_for :footer_menu_links, allow_destroy: true
  accepts_nested_attributes_for :social_links, allow_destroy: true
  accepts_nested_attributes_for :community_customizations

  after_create :initialize_settings

  monetize :minimum_price_cents, :allow_nil => true, :with_model_currency => :currency

  validates_length_of :ident, :in => 2..50
  validates_format_of :ident, :with => /\A[A-Z0-9_\-\.]*\z/i
  validates_uniqueness_of :ident
  validates_length_of :slogan, :in => 2..100, :allow_nil => true
  validates_format_of :custom_color1, :with => /\A[A-F0-9_-]{6}\z/i, :allow_nil => true
  validates_format_of :custom_color2, :with => /\A[A-F0-9_-]{6}\z/i, :allow_nil => true
  validates_format_of :slogan_color, :with => /\A[A-F0-9_-]{6}\z/i, :allow_nil => true
  validates_format_of :description_color, :with => /\A[A-F0-9_-]{6}\z/i, :allow_nil => true
  validates_length_of :custom_head_script, maximum: 65535

  VALID_BROWSE_TYPES = %w{grid map list}
  validates_inclusion_of :default_browse_view, :in => VALID_BROWSE_TYPES

  VALID_NAME_DISPLAY_TYPES = %w{first_name_only first_name_with_initial full_name}
  validates_inclusion_of :name_display_type, :in => VALID_NAME_DISPLAY_TYPES

  # The settings hash contains some community specific settings:
  # locales: which locales are in use, the first one is the default

  serialize :settings, Hash

  has_attached_file :logo,
                    :styles => {
                      :header => "192x192#",
                      :header_icon => "40x40#",
                      :header_icon_highres => "80x80#",
                      :apple_touch => "152x152#",
                      :original => "600x600>"
                    },
                    :convert_options => {
                      # iOS makes logo background black if there's an alpha channel
                      # And the options has to be in correct order! First background, then flatten. Otherwise it will
                      # not work.
                      :apple_touch => "-background white -flatten"
                    },
                    :keep_old_files => true

  validates_attachment_content_type :logo,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/pjpeg",
                                                      "image/x-png"]

  has_attached_file :wide_logo,
                    :styles => {
                      :header => "168x40#",
                      :paypal => "190x60>", # This logo is shown in PayPal checkout page. It has to be 190x60 according to PayPal docs.
                      :header_highres => "336x80#",
                      :original => "600x600>"
                    },
                    :convert_options => {
                      # The size for paypal logo will be exactly 190x60. No cropping, instead the canvas is extended with white background
                      :paypal => "-background white -gravity center -extent 190x60"
                    },
                    :keep_old_files => true

  validates_attachment_content_type :wide_logo,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/pjpeg",
                                                      "image/x-png"]

  has_attached_file :cover_photo,
                    :styles => {
                      :header => "1600x195#",
                      :hd_header => "1920x450#",
                      :original => "3840x3840>"
                    },
                    :default_url => ->(_){ ActionController::Base.helpers.asset_path("cover_photos/header/default.jpg") },
                    :keep_old_files => true

  validates_attachment_content_type :cover_photo,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/pjpeg",
                                                      "image/x-png"]

  has_attached_file :small_cover_photo,
                    :styles => {
                      :header => "1600x195#",
                      :hd_header => "1920x96#",
                      :original => "3840x3840>"
                    },
                    :default_url => ->(_) { ActionController::Base.helpers.asset_path("cover_photos/header/default.jpg") },
                    :keep_old_files => true

  validates_attachment_content_type :small_cover_photo,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/pjpeg",
                                                      "image/x-png"]

  has_attached_file :favicon,
                    :styles => {
                      :favicon => "32x32#"
                    },
                    :default_style => :favicon,
                    :convert_options => {
                      :favicon => "-depth 32 -strip",
                    },
                    :default_url => ->(_) { ActionController::Base.helpers.asset_path("favicon.ico") }

  validates_attachment_content_type :favicon,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/x-icon",
                                                      "image/vnd.microsoft.icon"]

  # process_in_background definitions have to be after
  # after all attachments: https://github.com/jrgifford/delayed_paperclip/issues/129
  process_in_background :logo
  process_in_background :wide_logo
  process_in_background :cover_photo
  process_in_background :small_cover_photo

  process_in_background :favicon

  before_save :cache_previous_image_urls

  FOOTER_THEMES = {
    FOOTER_DARK = 'dark'.freeze => 0,
    FOOTER_LIGHT = 'light'.freeze => 1,
    FOOTER_MARKETPLACE_COLOR = 'marketplace_color'.freeze => 2,
    FOOTER_LOGO = 'logo'.freeze => 3
  }.freeze
  enum footer_theme: FOOTER_THEMES

  def uuid_object
    if self[:uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:uuid])
    end
  end

  def uuid_object=(uuid)
    self.uuid = UUIDUtils.raw(uuid)
  end

  before_create :add_uuid
  def add_uuid
    self.uuid ||= UUIDUtils.create_raw
  end

  validates_format_of :twitter_handle, with: /\A[A-Za-z0-9_]{1,15}\z/, allow_nil: true

  validates :facebook_connect_id, numericality: { only_integer: true }, allow_nil: true
  validates :facebook_connect_id, length: {maximum: 16}, allow_nil: true

  validates_format_of :facebook_connect_secret, with: /\A[a-f0-9]{32}\z/, allow_nil: true

  attr_accessor :terms

  # Wrapper for the various attachment images url methods
  # which returns url of old image, while new one is processing.
  def stable_image_url(image_name, style = nil, options = {})
    image = send(:"#{image_name}")
    if image.processing?
      old_name = Rails.cache.read("c_att/#{id}/#{image_name}")
      return image.url(style, options) unless old_name

      # Temporarily set processing to false and the file name to the
      # old file name, so that we can call Paperclip's own url method.
      new_name = image.original_filename
      send(:"#{image_name}_processing=", false)
      send(:"#{image_name}_file_name=", old_name)

      url = image.url(style, options)

      send(:"#{image_name}_file_name=", new_name)
      send(:"#{image_name}_processing=", true)

      url
    else
      image.url(style, options)
    end
  end

  def cache_previous_image_urls
    return unless has_changes_to_save?

    changes_to_save.select { |attribute, values|
      attachment_name = attribute.chomp("_file_name")
      attribute.end_with?("_file_name") && !send(:"#{attachment_name}_processing") && values[0]
    }.each { |attribute, values|
      attachment_name = attribute.chomp("_file_name")
      # Temporarily store previous attachment file name in cache
      # so that we can still link to it, while new attachment is being processed.
      # This should probably be switched to using new columns in model, so that
      # old link doesn't break if processing fails and cache expires.
      Rails.cache.write("c_att/#{id}/#{attachment_name}", values[0], expires_in: 5.minutes)
    }
    true
  end

  def name(locale)
    customization = Maybe(community_customizations.where(locale: locale).first).or_else {
      # We should not end up in a situation where the given locale is not found.
      # However, currently that is likely to happend, because:
      # - User has one locale
      # - User can join to multiple communities, which may not have user's locale available
      fallback_customisation = community_customizations.where(locale: default_locale).first
      if !(fallback_customisation && fallback_customisation.name)
        # Corner case: switching default language to a language without localisation.
        fallback_customisation = community_customizations.where("name IS NOT NULL").order(:updated_at).last
      end
      fallback_customisation
    }

    if customization
      customization.name
    else
      raise ArgumentError.new("Cannot find translation for marketplace name community_id: #{id}, locale: #{locale}")
    end
  end

  def full_name(locale)
    name(locale)
  end

  # If community name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def name_with_separator(locale)
    (name(locale).include?(" ") && locale.to_s.eql?("fi")) ? "#{name(locale)} " : name(locale)
  end

  # If community full name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def full_name_with_separator(locale)
    (full_name(locale).include?(" ") && locale.to_s.eql?("fi")) ? "#{full_name(locale)} " : full_name(locale)
  end

  def address
    location ? location.address : nil
  end

  def default_locale
    if settings && !settings["locales"].blank?
      return settings["locales"].first
    else
      return APP_CONFIG.default_locale
    end
  end

  def locales
   if settings && !settings["locales"].blank?
      return settings["locales"]
    else
      # if locales not set, return the short locales from the default list
      return Sharetribe::AVAILABLE_LOCALES.map { |l| l[:ident] }
    end
  end

  # Returns the emails of admins in an array
  def admin_emails
    admins.collect { |p| p.confirmed_notification_email_addresses } .flatten
  end

  def allows_user_to_send_invitations?(user)
    (users_can_invite_new_users && user.member_of?(self)) || user.has_admin_rights?(self)
  end

  def has_customizations?
    custom_color1 || custom_color2 || slogan_color || description_color || cover_photo.present? || small_cover_photo.present? || wide_logo.present? || logo.present?
  end

  def has_custom_stylesheet?
    if APP_CONFIG.preproduction
      preproduction_stylesheet_url.present?
    else
      stylesheet_url.present?
    end
  end

  def custom_stylesheet_url
    if APP_CONFIG.preproduction
      self.preproduction_stylesheet_url
    else
      self.stylesheet_url
    end
  end

  def self.with_customizations
    customization_columns = [
      "custom_color1",
      "custom_color2",
      "cover_photo_file_name",
      "small_cover_photo_file_name",
      "wide_logo_file_name",
      "logo_file_name"
    ]

    sql = customization_columns.map { |column_name| column_name + " IS NOT NULL" }.join(" OR ")

    where(sql)
  end

  def menu_link_attributes=(attributes)
    ids = []

    attributes.each_with_index do |(id, value), i|
      if menu_link = menu_links.find_by_id(id)
        menu_link.update_attributes(value.merge(sort_priority: i))
        ids << menu_link.id
      else
        menu_links.build(value.merge(sort_priority: i))
      end
    end

    links_to_destroy = menu_links.reject { |menu_link| menu_link.id.nil? || ids.include?(menu_link.id) }
    links_to_destroy.each { |link| link.destroy }
  end

  def self.find_by_email_ending(email)
    Community.all.find_each do |community|
      return community if community.allowed_emails && community.email_allowed?(email)
    end
    return nil
  end

  def new_members_during_last(time)
    community_memberships.where(:created_at => time.ago..Time.now).collect(&:person)
  end

  # Returns the full domain with default protocol in front
  def full_url
    full_domain(:with_protocol => true)
  end

  #returns full domain without protocol
  def full_domain(options= {})
    # assume that if port is used in domain config, it should
    # be added to the end of the full domain for links to work
    # This concerns usually mostly testing and development
    default_host, default_port = APP_CONFIG.domain.split(':')
    port_string = options[:port] || default_port
    if options[:testmode] == true  
      default_host = 'taxi-hawk.com'
    else  
      default_host = 'yelo.red'  
    end 
    if domain.present? && use_domain? # custom domain
      dom = domain
    else # just a subdomain specified
      dom = "#{self.ident}.#{default_host}"
      dom += ":#{port_string}" unless port_string.blank?
    end

    if options[:with_protocol] 
      #dom = "#{(APP_CONFIG.always_use_ssl.to_s == "true" ? "https://" : "http://")}#{dom}"
      dom = "#{"https://"}#{dom}"
    end

    if options[:admin]

      dom = "#{dom}/en/admin/getting_started_guide"
      puts " the domain link will be : "

    end

    return dom

  end

  # returns the community specific service name if such is in use
  # otherwise returns the global default
  def service_name
    if settings && settings["service_name"].present?
      settings["service_name"]
    else
      APP_CONFIG.global_service_name || "Sharetribe"
    end
  end

  def has_new_listings_since?(time)
    return listings.where("created_at > ?", time).present?
  end

  def get_new_listings_to_update_email(person)
    latest = person.last_community_updates_at

    selected_listings = listings
      .currently_open
      .where("updates_email_at > ? AND updates_email_at > created_at", latest)
      .order("updates_email_at DESC")
      .to_a

    additional_listings = 10 - selected_listings.length
    new_listings =
      if additional_listings > 0
        listings
          .currently_open
          .where("updates_email_at > ? AND updates_email_at = created_at", latest)
          .order("updates_email_at DESC")
          .limit(additional_listings)
          .to_a
      else
        []
      end

     selected_listings
      .concat(new_listings)
      .sort_by { |listing| listing.updates_email_at}
      .reverse
  end

  def self.find_by_allowed_email(email)
    email_ending = "@#{email.split('@')[1]}"
    where("allowed_emails LIKE ?", "%#{email_ending}%")
  end

  # Returns all the people who are admins in at least one tribe.
  def self.all_admins
    Person.joins(:community_memberships).where("community_memberships.admin = '1'").group("people.id")
  end

  def self.stylesheet_needs_recompile!
    Community.with_customizations.update_all(:stylesheet_needs_recompile => true)
  end

  # approves a membership pending email if one is found
  # if email is given, only approves if email is allowed
  # returns true if membership was now approved
  # false if it wasn't allowed or if already a member
  def approve_pending_membership(person, email_address=nil)
    membership = community_memberships.where(:person_id => person.id, :status => "pending_email_confirmation").first
    if membership && (email_address.nil? || email_allowed?(email_address))
      membership.update_attribute(:status, "accepted")
      return true
    end
    return false
  end

  def main_categories
    top_level_categories
  end

  def leaf_categories
    categories.reject { |c| !c.children.empty? }
  end

  # is it possible to pay for this listing via the payment system
  def payment_possible_for?(listing)
    listing.price && listing.price > 0 && payments_in_use?
  end

  # Deprecated
  #
  # There is a method `payment_type` is community service. Use that instead.
  def payments_in_use?
    active_payment_types.present?
  end

  def self.all_with_custom_fb_login
    begin
      where("facebook_connect_id IS NOT NULL")
    rescue Mysql2::Error
      # in some environments (e.g. Travis CI) the tables are not yet loaded when this is called
      # so return empty array, as it shouldn't matter in those cases
      return []
    end
  end

  def email_notification_types
    valid_types = Person::EMAIL_NOTIFICATION_TYPES.dup
    if !follow_in_use?
      valid_types.delete "email_about_new_listings_by_followed_people"
    end
    valid_types
  end

  def close_listings_by_author(author)
    listings.where(:author_id => author.id).update_all(:open => false)
  end

  def images_processing?
    logo.processing? ||
    wide_logo.processing? ||
    cover_photo.processing? ||
    small_cover_photo.processing? ||
    favicon.processing?
  end

  def as_json(options)
    attrs = super(options)
    uuid = UUIDUtils.parse_raw(attrs["uuid"])
    attrs.merge({"uuid" => uuid.to_s})
  end

  # FIXME-RF not the best place
  def active_payment_types
    supported = []
    supported << :paypal if PaypalHelper.paypal_active?(self.id)
    supported << :stripe if StripeHelper.stripe_active?(self.id)
    supported << :razorpay if RazorpayHelper.razorpay_active?(self.id)
    supported.size > 1 ? supported : supported.first
  end

  def is_person_only_admin(person)
    admins.count == 1 && admins.first == person
  end

  #returns "ok" if plan not expired, "warning" if plan expire time left is less than 5 days and "stop" if plan has expired.
  def check_if_plan_has_expired(expiry_date,plan_code)
    return "ok" if (Time.now < expiry_date - 5.days && plan_code == "trial") || (plan_code != "trial") #check if expiry time left to expire is more than 5 days
    return "stop" if Time.now > expiry_date #check if expiry time has passed
    return "warning"
  end

  def my_account
    people.where(:is_admin => true).last
  end

  def my_email
    my_account.try(:emails).try(:last).try(:address)
  end

  #yelo apis start

  def self.fetch_yelo_data(hsh,req_type)
    puts "fetching yelo plans"
    if Rails.env.production?
      uri = URI("https://api.yelo.red/rentals/billing/#{req_type}") 
      else 
      uri = URI("https://test-api-3027.yelo.red/rentals/billing/#{req_type}") 
    end
    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'})
    req.body = hsh
    begin
      req.body = req.body.to_json
      res1 = https.request(req)
      puts "response ################################### #{res1.body}"
      @authBody = JSON.parse(res1.body)
      if req_type == "changeRentalPlan"
        return @authBody
      else
        return @authBody["data"]        
      end
    rescue => exception
      puts "there was a exception ...."
    end 
  end

  def self.fetch_plans(access_token)
    puts "fetching yelo plans"
    hsh = HashWithIndifferentAccess.new
    hsh[:access_token] = access_token
    return fetch_yelo_data(hsh,"getRentalPlans")
  end

  def self.fetch_current_plan(access_token)
    puts "fetching yelo current plan"
    hsh = HashWithIndifferentAccess.new
    hsh[:access_token] = access_token
    response = fetch_yelo_data(hsh,"getCurrentPlan")
    return response[0] if response.present?
    return response
  end

  def self.set_default_plan(access_token)
    puts "set default plan for new marketplace"
    hsh = HashWithIndifferentAccess.new
    hsh[:access_token] = access_token
    return fetch_yelo_data(hsh,"setDefaultBilling")
  end

  def change_plan(access_token, plan_hsh, new_plan_id)
    puts "changing community yelo plan"
    hsh = HashWithIndifferentAccess.new
    hsh[:access_token] = access_token
    hsh[:plan_id] = new_plan_id.to_i
    #add_charge(plan_hsh, access_token)
    return Community.fetch_yelo_data(hsh,"changeRentalPlan")
  end
  #yelo apis end
  
  #auth apis start
  def add_card(access_token,payment_method)
    begin
      if Rails.env.production?
        @url     ="https://#{APP_CONFIG.auth_api_key}/billing/addCard"
        @authKey = APP_CONFIG.auth_api_key
      else
        @url     = "https://dev-#{APP_CONFIG.auth_api_key}:3018/billing/addCard"
        @authKey = APP_CONFIG.auth_api_key
      end
      uri = URI(@url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'});
      # debugger
      req.body ={			
        :access_token     => access_token,
        :user_id  => user_id,
        :auth_key  => @authKey,
        :offering  => 2,
        :payment_method => payment_method
      }.to_json
      res1 = https.request(req)
      @authBody = JSON.parse(res1.body)
      raise @authBody["message"] if @authBody["status"] == 201
      return @authBody
    rescue Exception => e
      puts "add_card exception"
      puts e
      raise e
    end
  end
  
  def my_card(access_token)
    begin
      if Rails.env.production?
        @url     ="https://#{APP_CONFIG.auth_api_key}/get_user_card"
        @authKey = APP_CONFIG.auth_api_key
      else
        @url     = "https://dev-#{APP_CONFIG.auth_api_key}:3018/get_user_card"
        @authKey = APP_CONFIG.auth_api_key
      end
      uri = URI(@url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'});
      # debugger
      req.body ={			
        :access_token     => access_token,
        :user_id  => user_id,
        :auth_key  => @authKey,
        :offering  => 2
      }.to_json
      res1 = https.request(req)
      return JSON.parse(res1.body)      
      # cards.where(:is_deleted => false).last
    rescue Exception => e
      puts "my_card exception"
      puts e
      raise e
    end
  end
  
  def add_charge(plan_hsh, access_token)
    begin
      if Rails.env.production?
        @url     ="https://#{APP_CONFIG.auth_api_key}/deduct_individual_payment"
        @authKey = APP_CONFIG.auth_api_key
      else
        @url     = "https://dev-#{APP_CONFIG.auth_api_key}:3018/deduct_individual_payment"
        @authKey = APP_CONFIG.auth_api_key
      end
      uri = URI(@url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      req = Net::HTTP::Post.new(uri.path, {'Content-Type' =>'application/json'});
      req.body ={			
        :access_token => access_token,
        :user_id => user_id,
        :amount => (Plan.calculate_amount(plan_hsh, Date.today) * 100).to_i,
        :description => "Charge of #{plan_hsh["name"]} plan for yelo rentals",
        :auth_key => @authKey,
        :offering => 2
      }.to_json
      res1 = https.request(req)
      return JSON.parse(res1.body)      
    rescue Stripe::StripeError => e
      puts "add_charge stripe error"
      puts e
      body = e.json_body
      raise e.json_body[:error][:message]
    rescue Exception => e
      puts "add_charge exception"
      puts e
      raise e
    end
  end
  #auth apis end
  


  #Stripe<START>
  #Generate card token
  def self.create_card_token(data)
    begin
      Stripe.api_key = APP_CONFIG.admin_stripe_key
      token = Stripe::Token.create(:card => {:number => data[:number], :exp_month => data[:exp_month], :exp_year => data[:exp_year], :cvc => data[:cvc]})
      return token.id
    rescue Stripe::StripeError => e
      puts "create_card_token stripe error"
      puts e
      raise e.json_body[:error][:message]
    rescue Exception => e
      puts "create_card_token exception"
      puts e
      raise e
    end
  end
  #Stripe<END>

  def self.fugu_bot_token_added(auth_user,rtype,comment)
    if rtype == "successfully_added_card"
      message = "User with Email ID : " + auth_user["email"] + " added card in Yelo Rentals."
      subject = "Yelo Rentals : New Card Added"
    elsif rtype == "error_on_add_card"
      message = "User with Email ID : " + auth_user["email"] + " tried adding card in Yelo Rentals, error : " + comment; 
      subject = "Yelo Rentals : Add Card Error";
    end
    # fugu_token = APP_CONFIG.fugu_chat_token
    if Rails.env.production? && auth_user["internal_user"] == 0
      fugu_token = "8e60942492f1608c86ca97bf61581cd48a0839f0a32d75b6789a2199a672d6e85775a78260d2fb4a6fac846a2e933917"
    else 
      fugu_token = "a1d2fa31667d352b0bba0eaf7089834257d3e1893eb335aeeb60f22f92de7e5d"
    end
    fugu_url = "https://chat-api.fuguchat.com/api/webhook?token=#{fugu_token}"
    source = auth_user["source"]
    medium = auth_user["medium"] 
    sigupdate = auth_user["creation_datetime"]
    country = auth_user["country_phone_code"]
    messageq = "*" + subject + "*\n" +  message + "\nsource: " + auth_user["source"] + "\nmedium: " + auth_user["medium"] + "\ncountry: " + auth_user["country_phone_code"] + "\nsignup date: " + auth_user["creation_datetime"] + "\nlead_id: " + Maybe(auth_user["lead_id"]).or_else("")
    uri = URI(fugu_url)

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    req = Net::HTTP::Post.new(uri.path.concat("?token=#{fugu_token}"), {'Content-Type' =>'application/json'})
    req.body = { :data => { :message => messageq } }.to_json
    res = https.request(req)
  end

  def self.assign_trial_plan_to_new_communities
    trial_plan = Plan.where(plan_type: 0, billing_frequency: 0, is_enabled: true).first
    Community.all.each do |comm|
      comm.assign_plan(trial_plan) unless comm.community_billing.present?
    end
  end

  def check_days_left_for_plan_expiry(current_community_plan)
    (current_community_plan["expiry_datetime"].to_date-Date.today).to_i
  end

  def limited_plan_info(current_billing_plan)
    hsh = HashWithIndifferentAccess.new
    hsh[:plan_id] = current_billing_plan["plan_id"]
    hsh[:expiry_datetime] = current_billing_plan["expiry_datetime"].to_date.strftime("%b %d, %Y")
    return hsh
  end

  def self.update_landing_page_content
    Community.all.each do |community|
      get_released_version = CustomLandingPage::LandingPageStore.get_current_released_version(community.id)
      lp_data = CustomLandingPage::LandingPageStore.load_structure(community.id,get_released_version)
       lp_data["sections"].each_with_index do |section,index|
         if section["id"] == "hero"
         new_image = section["background_image"]["src"];
         new_variation = section["background_image_variation"];
         lp_data["sections"][index] = {
           "id"=> "hero",
           "kind"=> "hero",
           "variation"=> {"type"=> "marketplace_data", "id"=> "search_type"},
           "title"=> {"type"=> "marketplace_data", "id"=> "slogan"},
           "subtitle"=> {"type"=> "marketplace_data", "id"=> "description"},
           "background_image"=> {"src"=> new_image},
           "background_image_variation"=> new_variation,
           "search_button"=> {"type"=> "translation", "id"=> "search_button"},
           "search_path"=> {"type"=> "path", "id"=> "search"},
           "search_placeholder"=> {"type"=> "marketplace_data", "id"=> "search_placeholder"},
           "search_location_with_keyword_placeholder"=> {"type"=> "marketplace_data", "id"=> "search_location_with_keyword_placeholder"},
           "signup_path"=> {"type"=> "path", "id"=> "signup"},
           "signup_button"=> {"type"=> "translation", "id"=> "signup_button"},
           "search_button_color"=> {"type"=> "marketplace_data", "id"=> "primary_color"},
           "search_button_color_hover"=> {"type"=> "marketplace_data", "id"=> "primary_color_darken"},
           "signup_button_color"=> {"type"=> "marketplace_data", "id"=> "primary_color"},
           "signup_button_color_hover"=> {"type"=> "marketplace_data", "id"=> "primary_color_darken"}
           }
         end
       end
       CustomLandingPage::LandingPageStore.update_and_release_version!(community.id, get_released_version, lp_data.to_json)

    end
    return false
  end

  def self.assign_landing_page_to_all(comm_ids)
    where(id: comm_ids).each do |c|
      user_color = c.custom_color1 ? "##{c.custom_color1}" : "#4a90e2"
      user_color_without_hsh = c.custom_color1 ? "#{c.custom_color1}" : "4a90e2"
      primary_color_val = ColorUtils.css_to_rgb_array(user_color)
      darken_code = ColorUtils.brightness(user_color_without_hsh,85)
      primary_color_darken_val = ColorUtils.css_to_rgb_array(darken_code)            

      initial_json = c.add_marketplaceid_in_json(CustomLandingPage::StaticData::DATA_STR,primary_color_val,primary_color_darken_val)
      final_json = initial_json.to_json
      unless CustomLandingPage::LandingPageStore.check_if_landing_page_exist(c.id).present?
        CustomLandingPage::LandingPageStore.create_landing_page!(c.id)
      end
      if CustomLandingPage::LandingPageStore.check_if_version_exist(c.id, 1).present?
        CustomLandingPage::LandingPageStore.update_version!(c.id, 1, final_json)
      else
        CustomLandingPage::LandingPageStore.create_version!(c.id, 1, final_json)
      end
      if CustomLandingPage::LandingPageStore.check_if_version_exist(c.id, 2).present?
        CustomLandingPage::LandingPageStore.update_version!(c.id, 2, final_json)
      else
        CustomLandingPage::LandingPageStore.create_version!(c.id, 2, final_json)
      end
      if CustomLandingPage::LandingPageStore.check_if_version_exist(c.id, 3).present?
        CustomLandingPage::LandingPageStore.update_version!(c.id, 3, final_json)
      else
        CustomLandingPage::LandingPageStore.create_version!(c.id, 3, final_json)
      end
      CustomLandingPage::LandingPageStore.release_version!(c.id, 1)
      CustomLandingPage::LandingPageStore.disable_landing_page(c.id)
    end
  end

  def self.assign_landing_page_to_left_communities
    left_community_ids = CustomLandingPage::LandingPageStore.check_communities_without_landing_page
    p "Left community ids are:", left_community_ids
    where(id: left_community_ids).each do |c|
      user_color = c.custom_color1 ? "##{c.custom_color1}" : "#4a90e2"
      user_color_without_hsh = c.custom_color1 ? "#{c.custom_color1}" : "4a90e2"
      primary_color_val = ColorUtils.css_to_rgb_array(user_color)
      darken_code = ColorUtils.brightness(user_color_without_hsh,85)
      primary_color_darken_val = ColorUtils.css_to_rgb_array(darken_code)            

      initial_json = c.add_marketplaceid_in_json(CustomLandingPage::StaticData::DATA_STR,primary_color_val,primary_color_darken_val)
      final_json = initial_json.to_json
      unless CustomLandingPage::LandingPageStore.check_if_landing_page_exist(c.id).present?
        CustomLandingPage::LandingPageStore.create_landing_page!(c.id)
      end
      if CustomLandingPage::LandingPageStore.check_if_version_exist(c.id, 1).present?
        CustomLandingPage::LandingPageStore.update_version!(c.id, 1, final_json)
      else
        CustomLandingPage::LandingPageStore.create_version!(c.id, 1, final_json)
      end
      if CustomLandingPage::LandingPageStore.check_if_version_exist(c.id, 2).present?
        CustomLandingPage::LandingPageStore.update_version!(c.id, 2, final_json)
      else
        CustomLandingPage::LandingPageStore.create_version!(c.id, 2, final_json)
      end
      if CustomLandingPage::LandingPageStore.check_if_version_exist(c.id, 3).present?
        CustomLandingPage::LandingPageStore.update_version!(c.id, 3, final_json)
      else
        CustomLandingPage::LandingPageStore.create_version!(c.id, 3, final_json)
      end
      CustomLandingPage::LandingPageStore.release_version!(c.id, 1)
      CustomLandingPage::LandingPageStore.disable_landing_page(c.id)
    end
  end

  def add_marketplaceid_in_json(static_json,primary_color_val,primary_color_darken_val)
    parsed_data = JSON.parse(static_json)
    if parsed_data.keys.include?("settings").present?
      settings_data = parsed_data.find{|inner_data| inner_data.first == "settings"}
      if settings_data.present?
        if settings_data.second.keys.include?("marketplace_id")
          settings_data.second["marketplace_id"] = id
        end
      end
    end
    add_bgcolor_in_json(parsed_data,primary_color_val,primary_color_darken_val)
    return parsed_data
  end

  def add_bgcolor_in_json(parsed_data,primary_color_val,primary_color_darken_val)
    if parsed_data.keys.include?("sections").present?
      sections_data = parsed_data.find{|inner_data| inner_data.first == "sections"}
      if sections_data.present?
        sections_data.second.each do |a| 
          a.each do |key,value|
            if value.is_a? Hash
              if value["id"]=="primary_color"
                a[key] = {"value"=> primary_color_val}
              end
              if value["id"]=="primary_color_darken"
                a[key] = {"value"=> primary_color_darken_val}
              end
            end
          end
        end
      end
    end
    return parsed_data
  end

  def get_post_listing_name
    translation_t = CommunityTranslation.find_by(community_id:id,translation_key: 'homepage.index.post_new_listing')
    if translation_t.present?
      translation_t[:translation]
    else  
      "Post a new listing"
    end
  end
  
  #set default theme to communities without any theme
  def self.set_default_theme_to_communities
    selected_theme = Theme.first
    communities_ids_with_no_theme = ids - CommunityTheme.pluck(:community_id)
    communities_without_theme = where(id: communities_ids_with_no_theme)
    communities_without_theme.each do |community|
      community.community_themes.create(theme_id: selected_theme.id, content: selected_theme.content, enabled: true, released_at: Time.now)
    end
    return communities_ids_with_no_theme
  end
  
  def get_active_filter_detail
    res_arr = []
    if person_custom_fields.present?
      person_custom_fields.each do |cus_field|
        hsh = HashWithIndifferentAccess.new
        hsh[:id] = cus_field.id
        hsh[:type] = cus_field.type
        hsh[:entity_type] = cus_field.entity_type
        hsh[:name] = cus_field.name
        hsh[:search_filter] = cus_field.search_filter
        hsh[:min] = cus_field.min
        hsh[:max] = cus_field.max
        hsh[:required] = cus_field.required
        custom_field_option_arr = []
        cus_field.options.each do |op|
          inner_hsh = HashWithIndifferentAccess.new
          inner_hsh[:id] = op.id
          inner_hsh[:title] = op.title
          custom_field_option_arr.push inner_hsh
        end
        hsh[:custom_field_options] = custom_field_option_arr
        res_arr.push hsh
      end
    end
    return res_arr
  end

  def google_map_key_details
    hsh = HashWithIndifferentAccess.new
    hsh[:plan_type] = ""
    hsh[:client_id] = ""
    hsh[:map_key] = google_maps_key
    hsh[:signature] = "" 
  end

  #App Version message and status(0 => "All Okay.", 1 => "Minor Update", 2 => "Force Update")
  def app_version_message_and_status(user_version="", device_type)
    hsh = HashWithIndifferentAccess.new
    hsh[:status] = 0; hsh[:message] = ""; hsh[:store_link] = "" #default for every user(if no condition is matched)
    if device_type == "IOS" && user_version.present? #For ios devices with app versions
      hsh = app_version_message_and_status_for_ios(user_version,hsh)
    elsif device_type == "ANDROID" && user_version.present? #For android devices with app versions
      hsh = app_version_message_and_status_for_android(user_version,hsh)
    end
    return hsh
  end

  def app_version_message_and_status_for_ios(user_version="",hsh)
    if current_version_ios == force_update_version_ios #if both current and force update versions are same
      if user_version < force_update_version_ios #if user version is less than force update version
        hsh[:status] = 2; hsh[:message] = force_update_version_message; hsh[:store_link] = ios_store_link
      end
    elsif current_version_ios > force_update_version_ios #if current version is greater than forced version
      if user_version < current_version_ios && user_version >= force_update_version_ios #Update available
        hsh[:status] = 1; hsh[:message] = current_version_message; hsh[:store_link] = ios_store_link
      elsif user_version < force_update_version_ios #Force update require
        hsh[:status] = 2; hsh[:message] = force_update_version_message; hsh[:store_link] = ios_store_link
      end
    end
    return hsh
  end

  def app_version_message_and_status_for_android(user_version="",hsh)
    if current_version_android == force_update_version_android #if both current and force update versions are same
      if user_version < force_update_version_android #if user version is less than force update version
        hsh[:status] = 2; hsh[:message] = force_update_version_message; hsh[:store_link] = android_store_link
      end
    elsif current_version_android > force_update_version_android #if current version is greater than forced version
      if user_version < current_version_android && user_version >= force_update_version_android
        hsh[:status] = 1; hsh[:message] = current_version_message; hsh[:store_link] = android_store_link #Update available
      elsif user_version < force_update_version_android
        hsh[:status] = 2; hsh[:message] = force_update_version_message; hsh[:store_links] = android_store_link #Force update require
      end
    end
    return hsh
  end

  private

  def initialize_settings
    update_attribute(:settings,{"locales"=>[APP_CONFIG.default_locale]}) if self.settings.blank?
    true
  end

end

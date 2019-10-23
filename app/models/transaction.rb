# == Schema Information
#
# Table name: transactions
#
#  id                                :integer          not null, primary key
#  starter_id                        :string(255)      not null
#  starter_uuid                      :binary(16)       not null
#  listing_id                        :integer          not null
#  listing_uuid                      :binary(16)       not null
#  conversation_id                   :integer
#  automatic_confirmation_after_days :integer          not null
#  community_id                      :integer          not null
#  community_uuid                    :binary(16)       not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  starter_skipped_feedback          :boolean          default(FALSE)
#  author_skipped_feedback           :boolean          default(FALSE)
#  last_transition_at                :datetime
#  current_state                     :string(255)
#  commission_from_seller            :integer
#  minimum_commission_cents          :integer          default(0)
#  minimum_commission_currency       :string(255)
#  payment_gateway                   :string(255)      default("none"), not null
#  listing_quantity                  :integer          default(1)
#  listing_author_id                 :string(255)      not null
#  listing_author_uuid               :binary(16)       not null
#  listing_title                     :string(255)
#  unit_type                         :string(32)
#  unit_price_cents                  :integer
#  unit_price_currency               :string(8)
#  unit_tr_key                       :string(64)
#  unit_selector_tr_key              :string(64)
#  payment_process                   :string(31)       default("none")
#  delivery_method                   :string(31)       default("none")
#  shipping_price_cents              :integer
#  availability                      :string(32)       default("none")
#  booking_uuid                      :binary(16)
#  deleted                           :boolean          default(FALSE)
#  additional_info                   :json
#  additional_price                  :float(24)
#  checkout_field_price_cents        :integer          default(0)
#
# Indexes
#
#  index_transactions_on_community_id        (community_id)
#  index_transactions_on_conversation_id     (conversation_id)
#  index_transactions_on_deleted             (deleted)
#  index_transactions_on_last_transition_at  (last_transition_at)
#  index_transactions_on_listing_author_id   (listing_author_id)
#  index_transactions_on_listing_id          (listing_id)
#  index_transactions_on_starter_id          (starter_id)
#  transactions_on_cid_and_deleted           (community_id,deleted)
#

class Transaction < ApplicationRecord
  include ExportTransaction

  attr_accessor :contract_agreed

  belongs_to :community
  belongs_to :listing
  has_many :transaction_transitions, dependent: :destroy, foreign_key: :transaction_id
  has_one :booking, dependent: :destroy
  has_one :shipping_address, dependent: :destroy
  belongs_to :starter, class_name: "Person", foreign_key: :starter_id
  belongs_to :conversation
  has_many :testimonials
  belongs_to :listing_author, class_name: 'Person'
  has_many :transaction_checkout_fields 
  has_many :transaction_checkout_field_selections
  has_many :stripe_payments, dependent: :destroy
  
  delegate :author, to: :listing
  delegate :title, to: :listing, prefix: true

  accepts_nested_attributes_for :booking

  validates :payment_gateway, presence: true, on: :create
  validates :community_uuid, :listing_uuid, :starter_id, :starter_uuid, presence: true, on: :create
  validates :listing_quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}, on: :create
  validates :listing_title, :listing_author_id, :listing_author_uuid, presence: true, on: :create
  validates :unit_type, inclusion: ["hour", "day", "night", "week", "month", "custom", "unit", nil, :hour, :day, :night, :week, :month, :custom, :unit], on: :create
  validates :availability, inclusion: ["none", "booking", :none, :booking], on: :create
  validates :delivery_method, inclusion: ["none", "shipping", "pickup", nil, :none, :shipping, :pickup], on: :create
  validates :payment_process, inclusion: [:none, :postpay, :preauthorize], on: :create
  validates :payment_gateway, inclusion: [:paypal, :checkout, :braintree, :stripe, :razorpay, :none], on: :create
  validates :commission_from_seller, numericality: {only_integer: true}, on: :create
  validates :automatic_confirmation_after_days, numericality: {only_integer: true}, on: :create

  monetize :minimum_commission_cents, with_model_currency: :minimum_commission_currency
  monetize :unit_price_cents, with_model_currency: :unit_price_currency
  monetize :shipping_price_cents, allow_nil: true, with_model_currency: :unit_price_currency
  after_create :send_tx_notification

  scope :exist, -> { where(deleted: false) }
  scope :for_person, -> (person){
    joins(:listing)
    .where("listings.author_id = ? OR starter_id = ?", person.id, person.id)
  }
  scope :availability_blocking, -> do
    where(current_state: ['payment_intent_requires_action', 'preauthorized', 'paid', 'confirmed', 'canceled'])
  end
  scope :non_free, -> { where('current_state <> ?', ['free']) }
  scope :by_community, -> (community_id) { where(community_id: community_id) }
  scope :with_payment_conversation, -> {
    left_outer_joins(:conversation).merge(Conversation.payment)
  }
  scope :with_payment_conversation_latest, -> (sort_direction) {
    with_payment_conversation.order(
      "GREATEST(COALESCE(transactions.last_transition_at, 0),
        COALESCE(conversations.last_message_at, 0)) #{sort_direction}")
  }
  scope :for_csv_export, -> {
    includes(:starter, :booking, :testimonials, :transaction_transitions, :conversation => [{:messages => :sender}, :listing, :participants], :listing => :author)
  }
  scope :for_testimonials, -> {
    includes(:testimonials, testimonials: [:author, :receiver], listing: :author)
    .where(current_state: ['confirmed', 'canceled'])
  }
  scope :search_by_party_or_listing_title, ->(pattern) {
    joins(:starter, :listing_author)
    .where("listing_title like :pattern
        OR (#{Person.search_by_pattern_sql('people')})
        OR (#{Person.search_by_pattern_sql('listing_authors_transactions')})", pattern: pattern)
  }
  scope :search_for_testimonials, ->(community, pattern) do
    with_testimonial_ids = by_community(community.id)
    .left_outer_joins(testimonials: [:author, :receiver])
    .where("
      testimonials.text like :pattern
      OR #{Person.search_by_pattern_sql('people')}
      OR #{Person.search_by_pattern_sql('receivers_testimonials')}
    ", pattern: pattern).select("`transactions`.`id`")

    for_testimonials.joins(:listing, :starter, :listing_author)
    .where("
      `listings`.`title` like :pattern
      OR #{Person.search_by_pattern_sql('people')}
      OR #{Person.search_by_pattern_sql('listing_authors_transactions')}
      OR `transactions`.`id` IN (#{with_testimonial_ids.to_sql})
      ", pattern: pattern).distinct
  end

  def booking_uuid_object
    if self[:booking_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:booking_uuid])
    end
  end

  def booking_uuid_object=(uuid)
    self.booking_uuid = UUIDUtils.raw(uuid)
  end

  def community_uuid_object
    if self[:community_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:community_uuid])
    end
  end

  def starter_uuid_object
    if self[:starter_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:starter_uuid])
    end
  end

  def listing_author_uuid_object
    if self[:listing_author_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:listing_author_uuid])
    end
  end

  def starter_uuid=(value)
    write_attribute(:starter_uuid, UUIDUtils::RAW.call(value))
  end

  def listing_uuid=(value)
    write_attribute(:listing_uuid, UUIDUtils::RAW.call(value))
  end

  def community_uuid=(value)
    write_attribute(:community_uuid, UUIDUtils::RAW.call(value))
  end

  def listing_author_uuid=(value)
    write_attribute(:listing_author_uuid, UUIDUtils::RAW.call(value))
  end

  def booking_uuid=(value)
    write_attribute(:booking_uuid, UUIDUtils::RAW.call(value))
  end

  def status
    current_state
  end

  def has_feedback_from?(person)
    if author == person
      testimonial_from_author.present?
    else
      testimonial_from_starter.present?
    end
  end

  def feedback_skipped_by?(person)
    if author == person
      author_skipped_feedback?
    else
      starter_skipped_feedback?
    end
  end

  def testimonial_from_author
    testimonials.find { |testimonial| testimonial.author_id == author.id }
  end

  def testimonial_from_starter
    testimonials.find { |testimonial| testimonial.author_id == starter.id }
  end

  # TODO This assumes that author is seller (which is true for all offers, sell, give, rent, etc.)
  # Change it so that it looks for TransactionProcess.author_is_seller
  def seller
    author
  end

  # TODO This assumes that author is seller (which is true for all offers, sell, give, rent, etc.)
  # Change it so that it looks for TransactionProcess.author_is_seller
  def buyer
    starter
  end

  def participations
    [author, starter]
  end

  def payer
    starter
  end

  def payment_receiver
    author
  end

  def price_enabled 
    Maybe(listing.listing_shape.price_enabled).or_else(nil)
  end  

  def with_type(&block)
    block.call(:listing_conversation)
  end

  def latest_activity
    (transaction_transitions + conversation.messages).max
  end

  # Give person (starter or listing author) and get back the other
  #
  # Note: I'm not sure whether we want to have this method or not but at least it makes refactoring easier.
  def other_party(person)
    person == starter ? listing.author : starter
  end

  def other_party_app(person)
    other_user = conversation.try(:participations).other_party(person).last.person
    hsh = HashWithIndifferentAccess.new
    if other_user.present?
      hsh[:id] = other_user.id
      hsh[:given_name] = other_user.given_name
      hsh[:family_name] = other_user.family_name
      hsh[:displayed_name] = other_user.displayed_name
      hsh[:image_url] = other_user.image_url
    end
    hsh

  end

  def listing_owner
    hsh = HashWithIndifferentAccess.new
    hsh[:id] = author.id
    hsh[:given_name] = author.given_name
    hsh[:family_name] = author.family_name
    hsh[:displayed_name] = author.displayed_name
    hsh[:image_url] = author.image_url
    return hsh

  end

  def unit_type
    Maybe(read_attribute(:unit_type)).to_sym.or_else(nil)
  end

  def item_total
    tx_additional_price = Maybe(Money.new(self.checkout_field_price_cents,self.unit_price_currency.presence || self.community.currency)).or_else(0)
    ( unit_price * listing_quantity ) + tx_additional_price
  end

  def payment_gateway
    read_attribute(:payment_gateway)&.to_sym
  end

  def payment_process
    read_attribute(:payment_process)&.to_sym
  end

  def commission
    [(item_total * (commission_from_seller / 100.0) unless commission_from_seller.nil?),
     (minimum_commission unless minimum_commission.nil? || minimum_commission.zero?),
     Money.new(0, item_total.currency)]
      .compact
      .max
  end

  def commission_price
    commission.present? ? commission.fractional : ""
  end

  def commission_currency
    commission.present? ? commission.currency : ""
  end

  def waiting_testimonial_from?(person_id)
    if starter_id == person_id && starter_skipped_feedback
      false
    elsif listing_author_id == person_id && author_skipped_feedback
      false
    else
      testimonials.detect{|t| t.author_id == person_id}.nil?
    end
  end

  def mark_as_seen_by_current(person_id)
    self.conversation
      .participations
      .where("person_id = '#{person_id}'")
      .update_all(is_read: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def payment_total
    tx_total_payment = 0 
    unit_price       = self.unit_price || 0
    quantity         = self.listing_quantity || 1
    shipping_price   = self.shipping_price || 0
    additional_price = Maybe(Money.new(self.checkout_field_price_cents,self.unit_price_currency || self.community.currency)).or_else(0)
    if unit_price > 0
      tx_total_payment =  (unit_price * quantity) + shipping_price + additional_price
    else   
      tx_total_payment = (unit_price * quantity) + shipping_price
    end   
    tx_total_payment
  end
   
  def all_listing_images
    listing.listing_images
  end
    
    #1 => "accept_reject_btn", 2 => mark_as_complete_dispute, 3 => feedback and skip feedback
    def get_conversation_btns(current_user)
      btn = 0 #default
      return btn unless listing && !status.eql?("free")
      is_author = current_user == listing.author ? true : false
      case status
      when "paid"  
        btn = 2 unless seller == current_user
      when "preauthorized"
        btn = 1 if current_user.id.eql?(listing.author.id)
      when "rejected", "errored"
        btn = 0
      when "confirmed", "canceled"
        btn = 3 unless has_feedback_from?(current_user) || feedback_skipped_by?(current_user)
      end
      return btn
    end  
    
  def get_conversation_statuses(current_user)
    return [] unless listing && !status.eql?("free")
    is_author = current_user == listing.author ? true : false
    case status
    when "paid"
      msgs = ["Payment successful", delivery_status(current_user), paid_status(current_user)]
    when "preauthorized"
      msgs = ["Payment authorized", preauthorized_status(current_user)]
    when "rejected"
      msgs = ["Rejected"]
    when "confirmed"
      msgs = ["Completed", feedback_status(current_user)]
    when "canceled"
      msgs = ["Canceled", feedback_status(current_user)]
    when "errored"
      msgs = current_user == author ? ["Payment failed. Please contact #{starter.name(community)} and ask them to try the payment again."] : ["Payment failed. Please try again. If the problem continues, please contact Yelo support."]
    else
      msgs = []
    end
    return msgs.compact
  end

  def paid_status(current_user)
    if seller == current_user
      waiting_for_buyer_to_confirm(current_user)
    end
  end

  def waiting_for_buyer_to_confirm(current_user)
    if payment_gateway == :stripe
      return "Waiting for #{other_party(current_user).displayed_name} to mark the order completed. Once the order is marked as completed, the payment will be released to your bank account."
    else
      return "Waiting for #{other_party(current_user).displayed_name} to mark the order completed"
    end
  end

  def delivery_status(current_user)
    if current_user.id.eql?(author.id)
      "Waiting for you to fulfill the order for #{listing.title}"
    else
      "Waiting for #{author.displayed_name} to fulfill the order for #{listing.title}"
    end
  end
  
  def preauthorized_status(current_user)
    unless current_user.id.eql?(listing.author.id)
      "Waiting for #{author.displayed_name} to accept the request. As soon as #{author.displayed_name} accepts, you will be charged."
    end
  end
  
  def feedback_status(current_user)
    if has_feedback_from?(current_user)
      "Feedback given"
    elsif feedback_skipped_by?(current_user)
      "Feedback skipped"
    end
  end
 
  #Send Transaction Notification
  def send_tx_notification
    sender = starter
    hsh = HashWithIndifferentAccess.new
    hsh[:title] = sender.displayed_name 
    hsh[:description] = "New Booking"
    hsh[:notification_sender_id] = sender.id
    hsh[:notification_sender_name] = sender.displayed_name
    hsh[:notification_sender_image] = sender.image_url
    hsh[:notification_type] = 1 #checkout/send_message
    hsh[:notification_type_id] = id
    hsh[:conversation_id] = conversation_id
    hsh[:starting_page] = conversation.starting_page
    hsh[:participation_id] = conversation.participations.other_party(sender).first.id
    hsh[:notification_count] = InboxService.notification_count(author.id, author.community_id)
    hsh[:data] = HashWithIndifferentAccess.new
    author.send_notification(hsh)
  end
 
  #accept payment notification
  def accept_reject_payment_notification(status)
    sender = author
    sender_name = sender.displayed_name
    hsh = HashWithIndifferentAccess.new
    if status == :paid
      hsh[:title] = "Payment accepted"
      hsh[:description] = "Payment accepted by #{sender_name} for listing #{listing.title}, waiting for you to mark the order completed."
    else
      hsh[:title] = "Payment rejected"
      hsh[:description] = "Payment rejected by #{sender_name} for listing #{listing.title}."
    end
    hsh[:notification_sender_id] = sender.id
    hsh[:notification_sender_name] = sender_name
    hsh[:notification_sender_image] = sender.image_url
    hsh[:notification_type] = 3 #accepted/rejected
    hsh[:notification_type_id] = id
    hsh[:conversation_id] = conversation_id
    hsh[:starting_page] = conversation.starting_page
    hsh[:participation_id] = conversation.participations.other_party(sender).first.id
    hsh[:notification_count] = InboxService.notification_count(starter.id, starter.community_id)
    inner_data_hsh = HashWithIndifferentAccess.new
    inner_data_hsh[:conversation_statuses] = get_conversation_statuses(author) #For receiver's status messages
    inner_data_hsh[:conversation_btns] = get_conversation_btns(author) #For receiver's status buttons
    inner_data_hsh[:current_state] = current_state
    hsh[:data] = inner_data_hsh
    starter.send_notification(hsh)
  end
 
  #Mark as complete/Cancel(Disputed) payment notification
  def complete_cancel_payment_notification(status)
    sender = starter
    sender_name = sender.displayed_name
    hsh = HashWithIndifferentAccess.new
    if status == :confirmed
      hsh[:title] = "Booking completed"
      hsh[:description] = "Booking marked as complete by #{sender_name} for listing #{listing.title}, waiting for you to give feedback."
    else
      hsh[:title] = "Booking canceled"
      hsh[:description] = "Booking canceled by #{sender_name} for listing #{listing.title}, waiting for you to give feedback."
    end
    hsh[:notification_sender_id] = sender.id
    hsh[:notification_sender_name] = sender_name
    hsh[:notification_sender_image] = sender.image_url
    hsh[:notification_type] = 4 #complete/cancel
    hsh[:notification_type_id] = id
    hsh[:conversation_id] = conversation_id
    hsh[:starting_page] = conversation.starting_page
    hsh[:participation_id] = conversation.participations.other_party(sender).first.id
    hsh[:notification_count] = InboxService.notification_count(author.id, author.community_id)
    inner_data_hsh = HashWithIndifferentAccess.new
    inner_data_hsh[:conversation_statuses] = get_conversation_statuses(author) #For receiver's status messages
    inner_data_hsh[:conversation_btns] = get_conversation_btns(author) #For receiver's status buttons
    inner_data_hsh[:current_state] = current_state
    hsh[:data] = inner_data_hsh
    author.send_notification(hsh)
  end

  def add_checkout_fieds_to_transaction(checkout_fields, current_community)
    if checkout_fields
      if requiresJSONParse(checkout_fields)
        checkout_fields = JSON.parse(checkout_fields)
      end  
      checkout_fields.each do |cf|
        case cf["field_type"]
        when "DropdownField"
          selected_options = cf["value"]
          if requiresJSONParse(selected_options)
            selected_options = JSON.parse(selected_options)
          end  
          tcf = current_community.transaction_checkout_fields.create(:transaction_id => id, :title => cf["title"],:field_type => cf["field_type"])
          selected_options.each do |sv|            
            tcf.transaction_checkout_field_selections.create(:community_id => current_community.id,:transaction_id => id, :label => sv["label"], :value => sv["value"], :description => sv["description"] )
          end
        else   
          current_community.transaction_checkout_fields.create(:transaction_id => id, :title => cf["title"],:field_type => cf["field_type"], :value => cf["value"] )
        end 
      end
    end

  end

  def requiresJSONParse(unit) 
    begin 
      JSON.parse(unit) 
      return true 
    rescue => e 
      return false 
    end 
  end

end
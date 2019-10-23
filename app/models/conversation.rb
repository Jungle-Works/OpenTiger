# == Schema Information
#
# Table name: conversations
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  listing_id      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  last_message_at :datetime
#  community_id    :integer
#  starting_page   :string(255)
#
# Indexes
#
#  index_conversations_on_community_id     (community_id)
#  index_conversations_on_last_message_at  (last_message_at)
#  index_conversations_on_listing_id       (listing_id)
#  index_conversations_on_starting_page    (starting_page)
#

class Conversation < ApplicationRecord
  STARTING_PAGES = [
    PROFILE = 'profile',
    LISTING = 'listing',
    PAYMENT = 'payment'
  ]

  has_many :messages, :dependent => :destroy

  has_many :participations
  has_many :participants, :through => :participations, :source => :person
  belongs_to :listing
  has_one :tx, class_name: "Transaction", foreign_key: "conversation_id"
  belongs_to :community

  validates :starting_page, inclusion: { in: STARTING_PAGES }, allow_nil: true

  scope :for_person, -> (person){
    joins(:participations)
    .where( { participations: { person_id: person.id }} )
  }
  scope :non_payment, -> { where('starting_page IS NULL OR starting_page!=?', [PAYMENT]) }
  scope :payment, -> { where('starting_page IS NULL OR starting_page=?', [PAYMENT]) }
  scope :by_community, -> (community) { where(community: community) }
  scope :non_payment_or_free, -> (community) do
    subquery = Transaction.non_free.by_community(community.id).select('conversation_id').to_sql
    by_community(community).where("conversations.id NOT IN (#{subquery})").non_payment
  end
  scope :by_keyword, -> (community, pattern) do
    person_ids_sql = Person.search_name_or_email(community.id, pattern).select('people.id').to_sql
    person_conversations_subquery = joins(:participants).where("people.id IN (#{person_ids_sql})").select('conversations.id').to_sql
    by_community(community)
    .joins(:messages).where("
      (conversations.id IN (#{person_conversations_subquery}))
      OR
      (messages.content LIKE :pattern)
    ", pattern: pattern)
  end

  # Creates a new message to the conversation
  def message_attributes=(attributes)
    if attributes[:content].present? || attributes[:action].present?
      messages.build(attributes)
    end
  end

  # Sets the participants of the conversation
  def conversation_participants=(conversation_participants)
    conversation_participants.each do |participant, is_sender|
      last_at = is_sender.eql?("true") ? "last_sent_at" : "last_received_at"
      participations.build(:person_id => participant,
                           :is_read => is_sender,
                           :is_starter => is_sender,
                           last_at.to_sym => DateTime.now)
    end
  end

  def participation_for(person)
    participations.by_person(person)
  end

  def build_starter_participation(person)
    participations.build(
      person: person,
      is_read: true,
      is_starter: true,
      last_sent_at: DateTime.now
    )
  end

  def build_participation(person)
    participations.build(
      person: person,
      is_read: false,
      is_starter: false,
      last_received_at: DateTime.now
    )
  end

  # Returns last received or sent message
  def last_message
    return messages.last
  end

  def self.inbox_payment(inbox_item)
    Maybe(inbox_item)[:payment_total].or_else(nil)
  end

  def self.inbox_title(inbox_item, payment_sum)
    title = if InboxService.last_activity_type(inbox_item) == :message
      inbox_item[:last_message_content]
    else
      action_messages = TransactionViewUtils.create_messages_from_actions(
        inbox_item[:transitions],
        inbox_item[:other],
        inbox_item[:starter],
        payment_sum,
        inbox_item[:payment_gateway],
        inbox_item[:community_id]
      )

      # action_messages.last[:content]
      action_messages.present? ? action_messages.last[:content] : "No message found."
    end
  end

  def first_message
    return messages.first
  end

  def other_party(person)
    participations.other_party(person).first.try(:person)
  end
  
  def other_party_my_hsh(person)
    respo = other_party(person)
    hsh = HashWithIndifferentAccess.new
    hsh[:given_name] = respo.displayed_name
    hsh[:image_url]  = respo.image_url
    hsh[:id]         = respo.id
    return hsh
  end

  def read_by?(person)
    participation_for(person).is_read
  end

  def read_by_app?(person)
    participation_for(person).try(:last).is_read
  end

  # Send email notification to message receivers and returns the receivers
  #
  # TODO This should be removed. It's not model's resp to send emails.
  def send_email_to_participants(community)
    recipients(messages.last.sender).each do |recipient|
      if recipient.should_receive?("email_about_new_messages")
        MailCarrier.deliver_now(PersonMailer.new_message_notification(messages.last, community))
      end
    end
  end

  # Returns all the participants except the message sender
  def recipients(sender)
    participants.reject { |p| p.id == sender.id }
  end

  def starter
    participations.starter.first.try(:person)
  end

  def recipient
    participations.recipient.first.try(:person)
  end

  def participant?(user)
    participations.by_person(user).any?
  end

  def with_type(&block)
    block.call(:conversation)
  end

  def with(expected_type, &block)
    with_type do |own_type|
      if own_type == expected_type
        block.call
      end
    end
  end

  def mark_as_read(person_id)
    participations
      .where({ person_id: person_id })
      .update_all({is_read: true}) # rubocop:disable Rails/SkipsModelValidations
  end

  def self.all_conversation_hsh(all_conversations, community, my_detail)
    hsh = HashWithIndifferentAccess.new
    hsh[:message] = "Success"
    hsh[:status] = 200
    hsh[:data] = convesation_hsh(all_conversations, community, my_detail)
  end

  def self.convesation_hsh(all_data, community, my_detail)
    final_array = []
    notification_count = InboxService.notification_count(my_detail.id,  community.id)
    all_data.each do |data|
      status = data[:last_transition_to_state]
      conversation = Conversation.find(data[:conversation_id])
      status_description = ""
      if status.present? && status != "free"
        status_meta = data[:transitions].last[:metadata]
        is_author = !data[:current_is_starter]
        waiting_feedback = data[:waiting_feedback]
        other_name = PersonViewUtils.person_display_name(data[:other], community)
        status_description = conversation.conversation_msg_status(status, is_author, other_name, waiting_feedback, status_meta)
      end
      starting_pg = conversation.starting_page
      starting_pg = conversation.tx.present? ? "payment" : "" if starting_pg.nil? 
      puts " the con s p  ", conversation.starting_page , " data id : " , data[:id]
      hsh = HashWithIndifferentAccess.new
      hsh[:id] = ""
      hsh[:notification_count] = notification_count
      conversation_hsh = HashWithIndifferentAccess.new
      last_message_hsh = HashWithIndifferentAccess.new
      last_message_hsh[:id] = ""
      last_message_hsh[:content] = inbox_title(data, inbox_payment(data))
      conversation_hsh[:id] = data[:conversation_id]
      conversation_hsh[:last_message_at] = data[:last_activity_at]
      conversation_hsh[:message] = last_message_hsh
      conversation_hsh[:starting_page] = starting_pg
      conversation_hsh[:is_read] = !data[:should_notify]
      conversation_hsh[:conversation_msg_status] = status_description
      conversation_hsh[:current_state] = conversation.tx.present? ? conversation.tx.current_state : ""
      person_hsh = HashWithIndifferentAccess.new
      person_hsh[:id] = data[:other].id
      person_hsh[:given_name] = data[:other].displayed_name
      person_hsh[:image_url] = data[:other].image_url
      conversation_hsh[:other_party] = person_hsh
      hsh[:conversation] = conversation_hsh
      final_array.push hsh
    end
    return final_array
  end
    
  def conversation_msg_status(status, is_author, other_name, waiting_feedback, status_meta)
    status = if waiting_feedback
      "waiting_feedback"
    else
      "completed"
    end if status == "confirmed"
    case status
    when "pending", "preauthorized"
      is_author.present? ? "Waiting for you to accept the request" : "Waiting for #{listing.author.displayed_name} to accept the request. As soon as #{listing.author.displayed_name} accepts, you will be charged."
    when "accepted"
      is_author.present? ? "Waiting for #{other_name} to pay" : "Waiting for you to pay"
    when "paid"
      is_author.present? ? "Waiting for #{other_name} to mark the order completed" : "Waiting for you to mark the order completed"
    when "rejected"
      "Rejected"
    when "confirmed"
      "Completed"
    when "canceled"
      "Canceled"
    when "waiting_feedback"
      "Waiting for you to give feedback"
    when "errored"
      "Payment failed. Please try again."
    else
      ""
    end
  end


end

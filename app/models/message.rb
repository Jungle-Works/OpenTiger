# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  sender_id       :string(255)
#  content         :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  conversation_id :integer
#
# Indexes
#
#  index_messages_on_conversation_id  (conversation_id)
#

class Message < ApplicationRecord

  after_save :update_conversation_read_status

  belongs_to :sender, :class_name => "Person"
  belongs_to :conversation

  validates_presence_of :sender_id
  validates_presence_of :content
  after_create_commit :send_msg_notification

  scope :latest_for_conversation, -> {
    joins('LEFT JOIN messages m2 ON
          (messages.conversation_id = m2.conversation_id AND messages.created_at < m2.created_at)')
    .where('m2.created_at IS NULL')
  }
  scope :by_converation_ids, -> (converation_ids) { where(conversation_id: converation_ids) }
  scope :latest, -> { order('messages.created_at DESC') }

  def update_conversation_read_status
    conversation.update_attribute(:last_message_at, created_at)
    conversation.participations.each do |p|
      last_at = p.person.eql?(sender) ? :last_sent_at : :last_received_at
      p.update_attributes({ :is_read => p.person.eql?(sender), last_at => created_at})
    end
  end

  def receiver
    conversation.participations.where.not(:person_id => sender_id).last.person
  end

   #Send Message Notification
   def send_msg_notification
    msg_receiver = receiver
    hsh = HashWithIndifferentAccess.new
    hsh[:title] = sender.displayed_name
    hsh[:description] = content
    hsh[:notification_sender_id] = sender.id
    hsh[:notification_sender_name] = sender.displayed_name  
    hsh[:notification_sender_image] = sender.image_url
    hsh[:notification_type] = 1 #send_message
    hsh[:notification_type_id] = id
    hsh[:conversation_id] = conversation_id
    hsh[:starting_page] = conversation.starting_page
    hsh[:participation_id] = conversation.participations.other_party(msg_receiver).first.id
    hsh[:notification_count] = InboxService.notification_count(msg_receiver.id, msg_receiver.community_id)
    hsh[:data] = HashWithIndifferentAccess.new
    puts "the send message notfication created the following hash : " , hsh
    msg_receiver.send_notification(hsh)
  end
end

# == Schema Information
#
# Table name: tb_active_app_sessions
#
#  id            :integer          not null, primary key
#  person_id     :string(255)
#  community_id  :integer
#  session_token :string(255)      not null
#  device_token  :string(255)
#  device_type   :string(255)
#  refreshed_at  :datetime         not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_tb_active_app_sessions_on_person_id      (person_id)
#  index_tb_active_app_sessions_on_session_token  (session_token) UNIQUE
#

class TbActiveAppSession < ApplicationRecord
    validates_presence_of :person_id
    validates_presence_of :session_token
    validates_presence_of :refreshed_at
    validates_presence_of :community_id

    belongs_to :person
    belongs_to :community
end

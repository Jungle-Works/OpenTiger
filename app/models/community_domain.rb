# == Schema Information
#
# Table name: community_domains
#
#  id              :integer          not null, primary key
#  community_id    :integer
#  custom_domain   :string(255)
#  previous_domain :string(255)
#  in_processing   :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CommunityDomain < ApplicationRecord
  belongs_to :community
end

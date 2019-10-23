# == Schema Information
#
# Table name: community_themes
#
#  id           :integer          not null, primary key
#  community_id :integer          not null
#  theme_id     :integer          not null
#  content      :text(16777215)   not null
#  enabled      :boolean          default("Inactive")
#  released_at  :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_community_themes_on_community_id  (community_id)
#  index_community_themes_on_theme_id      (theme_id)
#

class CommunityTheme < ApplicationRecord
    belongs_to :community
    belongs_to :theme
   
    ENABLESTATUS = {
        INACTIVE = 'Inactive'.freeze => false,
        ACTIVE = 'Active'.freeze => true
      }
      enum enabled: ENABLESTATUS

end

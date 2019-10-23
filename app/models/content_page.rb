# == Schema Information
#
# Table name: content_pages
#
#  id           :integer          not null, primary key
#  title        :string(255)
#  data         :text(16777215)   not null
#  end_point    :string(255)
#  community_id :integer
#  is_deleted   :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  is_active    :boolean          default(TRUE)
#

class ContentPage < ApplicationRecord
    belongs_to :community
end

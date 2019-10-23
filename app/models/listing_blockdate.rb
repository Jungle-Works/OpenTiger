# == Schema Information
#
# Table name: listing_blockdates
#
#  id         :integer          not null, primary key
#  listing_id :string(255)
#  date       :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ListingBlockdate < ApplicationRecord
	belongs_to :listing
end

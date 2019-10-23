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

require 'rails_helper'

RSpec.describe ListingBlockdate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

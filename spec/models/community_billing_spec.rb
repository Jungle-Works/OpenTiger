# == Schema Information
#
# Table name: community_billings
#
#  id                          :integer          not null, primary key
#  community_id                :integer
#  plan_id                     :integer
#  amount                      :decimal(8, 2)
#  credits                     :decimal(8, 2)
#  per_day_cost                :decimal(8, 2)
#  expiry_datetime             :datetime
#  offline_payment             :boolean          default(FALSE)
#  billing_status              :boolean          default(FALSE)
#  first_plan_purchased_time   :datetime
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  last_expiry_popup_view_date :date
#
# Indexes
#
#  index_community_billings_on_community_id  (community_id)
#  index_community_billings_on_plan_id       (plan_id)
#

require 'rails_helper'

RSpec.describe CommunityBilling, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

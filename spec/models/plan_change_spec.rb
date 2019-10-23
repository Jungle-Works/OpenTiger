# == Schema Information
#
# Table name: plan_changes
#
#  id           :integer          not null, primary key
#  community_id :integer
#  old_plan_id  :integer
#  new_plan_id  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'rails_helper'

RSpec.describe PlanChange, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

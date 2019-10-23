# == Schema Information
#
# Table name: plans
#
#  id                :integer          not null, primary key
#  name              :string(255)      default("")
#  description       :string(255)      default("")
#  plan_type         :integer          default(0)
#  billing_frequency :integer          default(0)
#  price             :decimal(8, 2)
#  currency          :string(255)      default("$")
#  per_day_cost      :decimal(8, 2)
#  months            :integer          default(0)
#  is_enabled        :boolean          default(TRUE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  content           :text(16777215)   not null
#  discounted_price  :decimal(8, 2)
#  plan_code         :string(255)      default("")
#

require 'rails_helper'

RSpec.describe Plan, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

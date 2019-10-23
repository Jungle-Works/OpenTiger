# == Schema Information
#
# Table name: checkout_fields
#
#  id            :integer          not null, primary key
#  people_id     :string(255)      not null
#  community_id  :integer          not null
#  sort_priority :integer
#  field_type    :string(255)
#  title         :string(255)
#  value         :string(255)
#  locale        :string(255)
#  is_required   :boolean          default(TRUE)
#  entity_type   :string(255)
#  min           :float(24)
#  max           :float(24)
#  is_deleted    :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_checkout_fields_on_community_id  (community_id)
#  index_checkout_fields_on_people_id     (people_id)
#

require 'rails_helper'

RSpec.describe CheckoutField, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

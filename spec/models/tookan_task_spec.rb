# == Schema Information
#
# Table name: tookan_tasks
#
#  id                     :integer          not null, primary key
#  listing_id             :integer
#  transaction_id         :integer
#  buyer_id               :string(255)
#  seller_id              :string(255)
#  tookan_job_id          :string(255)
#  tookan_pickup_id       :string(255)
#  tookan_delivery_id     :string(255)
#  job_pickup_address     :text(65535)
#  job_delivery_address   :text(65535)
#  task_delivery_charges  :float(24)
#  tookan_api_user_id     :string(255)
#  job_delivery_latitude  :float(24)
#  job_delivery_longitude :float(24)
#  job_pickup_latitude    :float(24)
#  job_pickup_longitude   :float(24)
#  pickup_required        :boolean
#  delivery_required      :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

require 'rails_helper'

RSpec.describe TookanTask, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

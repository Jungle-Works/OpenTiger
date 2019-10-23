# == Schema Information
#
# Table name: hippo_api_logs
#
#  id           :integer          not null, primary key
#  action       :string(255)
#  email        :string(255)
#  api_response :text(65535)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class HippoApiLog < ApplicationRecord
end

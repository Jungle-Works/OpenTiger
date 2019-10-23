# == Schema Information
#
# Table name: fugu_api_responses
#
#  id             :integer          not null, primary key
#  action         :string(255)
#  transaction_id :integer
#  api_response   :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FuguApiResponse < ApplicationRecord
end

# == Schema Information
#
# Table name: fugu_channels
#
#  id             :integer          not null, primary key
#  channel_id     :string(255)
#  transaction_id :integer
#  seller         :string(255)
#  buyer          :string(255)
#  workspace_id   :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class FuguChannel < ApplicationRecord
end

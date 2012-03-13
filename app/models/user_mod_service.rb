class UserModService < ActiveRecord::Base
  belongs_to :user_detail
	belongs_to :service
end

class UserShortCode < ActiveRecord::Base
  belongs_to :short_code
	belongs_to :user
  validates :short_code_id, :presence =>{:message => "Short code can't be blank"}
  validates :user_id, :presence =>{:message => "User can't be blank"}
end

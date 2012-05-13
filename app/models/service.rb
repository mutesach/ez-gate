class Service < ActiveRecord::Base
  has_many :inbound_message
	has_many :user_mod_service
	belongs_to :user
	belongs_to :web_service
  validates :name, :presence =>{:message => "Name can't be blank"}
  validates :keyword, :presence =>{:message => "Keyword can't be blank"}
  validates :user_id, :presence =>{:message => "User can't be blank"}
  validates :user_id, :presence =>{:message => "User can't be blank"}
  validates :user_short_code_id, :presence =>{:message => "Short code can't be blank"}
  validates :content_type, :presence =>{:message => "Content type can't be blank"}

	ContentType = [[ "Static" , "Static" ],[ "Dynamic" , "Dynamic" ]]
  Prefixes = [["+24381","+24381"],["+24382","+24382"],["+24383","+24383"]]
	def service_name
    "#{name}"
  end
end

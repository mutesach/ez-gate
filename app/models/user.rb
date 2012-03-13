class User < ActiveRecord::Base
  has_many :service
	has_many :user_detail
	has_many :user_short_code
	validates_presence_of :name, :user_type,	:phone_no
  validates_uniqueness_of :phone_no
  Types = [[ "Administrator","Administrator" ],
    [ "Service-Aggregator","Service-Aggregator" ],
    ["Bulk-push","Bulk-push"]]
  STAT_OPTION = [["Off", false ],["On", true ]]
  	
end

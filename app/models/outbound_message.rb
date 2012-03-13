class OutboundMessage < ActiveRecord::Base
  	belongs_to :inbound_message
end

class InboundMessage < ActiveRecord::Base
  belongs_to :service
	has_one :outbound_message
	MONTHS = [["January", 1 ],["February", 2 ], ["March", 3 ], ["April", 4],
    ["May", 5], ["June", 6], ["July", 7], ["August", 8], ["September", 9],
    ["October", 10], ["November", 11], ["December", 12]]
  YEARS = Array.new(21) {|i| 2009+i}

	TELECOM_OPERATORS = [["Vodacom DRC", "Vodacom DRC"],["Tigo DRC", "Tigo DRC"], ["Tigo Tchad", "Tigo Tchad"]]
end

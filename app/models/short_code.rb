class ShortCode < ActiveRecord::Base
  has_many :user_short_code
	validates :code, :presence =>{:message => "Short code can't be blank"}
  validates :smsc, :presence =>{:message => "SMSC can't be blank"}
  validates :sms_cost, :presence =>{:message => "SMS cost can't be blank"}

	SMSCS = [["Vodacom DRC", "Vodacom DRC"],["Tigo DRC", "Tigo DRC"], ["Tigo Tchad", "Tigo Tchad"]]
	def short_code_with_smsc #select customer id with name
    "#{code} #{smsc}"
  end

  def safe_delete
    transaction do
      destroy
      if ShortCode.count.zero?
        raise "Can't last short code"
      end
    end
  end
end

class RingtoneAccessKey < ActiveRecord::Base
  belongs_to :ringtone

  def self.validate(ringtone_id, key)
    ringtone = self.find_by_ringtone_id_and_key(ringtone_id, key)
    if ringtone
      if ringtone.req_status != "unused"
        ringtone = nil
      end
    end
    ringtone
  end


  def self.random_key(size)
    num = (('0'..'9').to_a)
    (1..size).collect{|a| num[rand(num.size)] }.join
  end
end

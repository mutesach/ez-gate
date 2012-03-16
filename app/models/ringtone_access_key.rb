class RingtoneAccessKey < ActiveRecord::Base
  belongs_to :ringtone

  def self.validate(ringtone_id, secret_key)
    ringtone = self.find_by_ringtone_id(ringtone_id)
    if ringtone
      expected_key = encrypted_key(secret_key, ringtone.salt)
      if ringtone.hashed_key != expected_key
        ringtone = nil
      end
    end
    ringtone
  end

  # virtual attribute
  def secret_key
    @secretkey
  end

  def secret_key=(pwd)
    @secretkey = pwd
    create_new_salt
    self.hashed_key = RingtoneAccessKey.encrypted_key(self.secret_key, self.salt)
  end

  private
  def self.encrypted_key(secret_key, salt)
    string_to_hash = secret_key + "ezgate2012" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

  def self.random_key(size)
    num = (('0'..'9').to_a)
    (1..size).collect{|a| num[rand(num.size)] }.join
  end
end

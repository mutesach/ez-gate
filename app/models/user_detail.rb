class UserDetail < ActiveRecord::Base
  belongs_to :user
	has_many :user_mod_service
  validates :username, :presence =>{:message => "Username can't be blank"}
  validates :password, :presence =>{:message => "Password can't be blank"}
  validates :password_confirmation, :presence =>{:message => "Confirm password"}

	validates_uniqueness_of :username
	validates_length_of :password, :minimum => 6,
    :message => "Password too short, minimum 6 characters"

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  def self.authenticate(username, password)
    user = self.find_by_username(username)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  def self.random_password(size)
    num = (('0'..'9').to_a)
    (1..size).collect{|a| num[rand(num.size)] }.join
  end

  # virtual attribute
  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = UserDetail.encrypted_password(self.password, self.salt)
  end

  def safe_delete
    transaction do
      destroy
      if UserDetail.count.zero?
        raise "Can't delete last user"
      end
    end
  end

  private
  def self.encrypted_password(password, salt)
    string_to_hash = password + "pivot2010" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end

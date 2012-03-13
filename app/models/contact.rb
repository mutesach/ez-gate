class Contact < ActiveRecord::Base
  validates :phone_no, :presence =>{:message => "Phone number can't be blank"}
  validates :group_id, :presence =>{:message => "Group can't be blank"}
end

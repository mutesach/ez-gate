class Group < ActiveRecord::Base
  validates :name, :presence =>{:message => "Group name can't be blank"}
end

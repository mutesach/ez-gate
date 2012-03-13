class WebService < ActiveRecord::Base
  has_many :service
  validates :name, :presence =>{:message => "Name can't be blank"}
  validates :web_service_type, :presence =>{:message => "Type can't be blank"}
  validates :web_service_uri, :presence =>{:message => "URI can't be blank"}

	#validates_uri_existence_of :web_service_uri, :with => /(^$)|(^(http|https):\/\/[a-z0-9])/ix
	Types = [[ "Get-URL" , "Get-URL" ],[ "POST-XML" , "POST-XML" ]]

	def safe_delete
    transaction do
      destroy
      if WebService.count.zero?
        raise "Can't delete last web service"
      end
    end
  end
end

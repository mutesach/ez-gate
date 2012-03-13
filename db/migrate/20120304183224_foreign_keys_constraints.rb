class ForeignKeysConstraints < ActiveRecord::Migration
  def up
    execute "alter table user_short_codes add constraint fk_user_short_codes_short_codes foreign key
						(short_code_id) references short_codes(id)"

		execute "alter table user_short_codes add constraint fk_user_short_codes_users foreign key
						(user_id) references users(id)"

		execute "alter table user_details add constraint fk_users_user_details foreign key
						(user_id) references users(id)"

		execute "alter table user_mod_services add constraint fk_user_mod_services_user_details foreign key
						(user_mod_id) references user_details(id)"

		execute "alter table user_mod_services add constraint fk_user_mod_services_services foreign key
						(service_id) references services(id)"

   	execute "alter table services add constraint fk_services_user_details foreign key
    				(user_id) references user_details(id)"

   	execute "alter table services add constraint fk_services_user_short_codes foreign key
   	 				(user_short_code_id) references user_short_codes(id)"

   	execute "alter table inbound_messages add constraint fk_inbound_messages_users foreign key
    				(user_id) references users(id)"

   	execute "alter table inbound_messages add constraint fk_inbound_messages_services foreign key
    				(service_id) references services(id)"

   	execute "alter table outbound_messages add constraint fk_outbound_messages_users foreign key
    				(user_id) references users(id)"


   	execute "alter table services add constraint fk_services_web_services foreign key
    				(web_service_id) references web_services(id)"

   	execute "alter table contacts add constraint fk_contacts_users foreign key
						(user_id) references users(id)"

		execute "alter table contacts add constraint fk_contacts_groups foreign key
						(group_id) references groups(id)"

    execute "alter table directories add constraint fk_directories_users foreign key
						(user_id) references users(id)"


    User.create(:user_type => "SA", :name => "Super-Administrator",
      :phone_no => "+250",	:email => "info@pivotaccess.com",
      :sms_limit => false, :sms_stock => 0)
    ShortCode.create(:code => "All",	:smsc => "*", :sms_cost => 0,	:status => true)
    UserShortCode.create(:user_id => 1, :short_code_id => 1)
    UserDetail.create(:user_id => 1, :username => "sa",
      :password => "123456", :password_confirmation => "123456",
      :status  => true, :parent => true)
    Group.create(:user_id => 1, :name => "default", :created_at => Time.now())
    WebService.create(:name => "default",	:web_service_type => "default",
      :web_service_uri => "http://localhost/")
    Service.create(:name => "unknown", :keyword => "unknown", :user_id => 1,
      :content_type => "Static", :reply => 0, :reply_content => nil,
      :web_service_id => 1, :user_short_code_id => 1, :status => true)
    Service.create(:name => "push", :keyword => "push", :user_id => 1,
      :content_type => "Static", :reply => 0, :reply_content => nil,
      :web_service_id => 1, :user_short_code_id => 1,:status => true)
  end

  def down
  end
end

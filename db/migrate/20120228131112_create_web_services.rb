class CreateWebServices < ActiveRecord::Migration
  def change
    create_table :web_services do |t|
      t.column :name, :string, :limit => 20, :null => false
			t.column :web_service_type, :string, :limit => 20, :null => false
			t.column :web_service_uri, :string, :limit => 500, :null => true
			t.column :post_xml_format, :string, :limit => 1000, :null => true
			t.column :default_param, :boolean, :null => false, :default => false
			t.column :param1, :string, :limit => 20, :null => true
			t.column :param2, :string, :limit => 20, :null => true
			t.column :param3, :string, :limit => 20, :null => true
			t.column :param4, :string, :limit => 20, :null => true
			t.column :param5, :string, :limit => 20, :null => true
			t.column :param6, :string, :limit => 20, :null => true
			t.column :param7, :string, :limit => 20, :null => true
			t.column :param8, :string, :limit => 20, :null => true
			t.column :param9, :string, :limit => 20, :null => true
			t.column :param10, :string, :limit => 20, :null => true
      t.timestamps
    end
    add_index :web_services, :name, :name => "idx_web_services_name"
		add_index :web_services, :web_service_type, :name => "idx_web_services_web_service_type"
  end
end

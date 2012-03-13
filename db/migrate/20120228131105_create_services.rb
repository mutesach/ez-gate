class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.column :name, :string, :limit => 30, :null => false
			t.column :keyword, :string, :limit => 10, :null => false
      t.column :aliases, :string, :limit => 200
			t.column :user_id, :integer, :null => false
			t.column :user_short_code_id, :integer, :null => false
			t.column :content_type, :string, :limit => 10, :null => false
			t.column :reply, :boolean, :null => false
			t.column :reply_content, :string, :limit => 170, :null => true
			t.column :web_service_id, :integer, :null => true
			t.column :status, :boolean, :null => false, :default => false
      t.timestamps
    end
    add_index :services, :keyword, :name => "idx_services_name"
		add_index :services, :user_id, :name => "idx_services_user_id"
		add_index :services, :content_type, :name => "idx_services_content_type"
  end
end

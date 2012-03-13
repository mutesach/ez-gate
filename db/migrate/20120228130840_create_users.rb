class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.column :user_type, :string, :limit => 20, :null => false
			t.column :name, :string, :limit => 30, :null => false
			t.column :phone_no, :string, :limit => 15, :null => false
			t.column :email, :string, :limit => 50, :null => false
			t.column :sms_limit, :boolean, :null => false, :default => false
			t.column :sms_stock, :integer, :null => false, :default => 0	
			t.timestamps
		end
		add_index :users, :name, :name => "idx_users_name"
		add_index :users, :email, :name => "idx_users_email"
		add_index :users, :phone_no, :name => "idx_users_phone_no"
  end
end

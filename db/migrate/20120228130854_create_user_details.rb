class CreateUserDetails < ActiveRecord::Migration
  def change
    create_table :user_details do |t|
      t.column :user_id, :integer, :null => true
			t.column :username, :string, :limit => 10, :null => false
			t.column :hashed_password, :string, :limit => 50, :null => false
			t.column :salt, :string, :limit => 50, :null => false
			t.column :parent, :boolean, :null => false, :default => false
			t.column :status, :boolean, :null => false, :default => false
			t.timestamps
		end
		add_index :user_details, :username, :name => "idx_user_details_username"
  end
end

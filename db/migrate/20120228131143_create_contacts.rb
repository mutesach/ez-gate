class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.column :user_id, :integer, :null => false
			t.column :group_id, :integer, :null => false
			t.column :name, :string, :limit => 30, :null => false
			t.column :phone_no, :string, :limit => 15, :null => false
      t.timestamps
    end
  end
end

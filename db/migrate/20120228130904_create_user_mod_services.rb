class CreateUserModServices < ActiveRecord::Migration
  def change
    create_table :user_mod_services do |t|
      t.column :user_mod_id, :integer, :null => true
			t.column :service_id, :integer, :null => true
      t.timestamps
    end
  end
end

class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.column :user_id, :integer, :null => false
			t.column :name, :string, :limit => 50, :null => false
      t.timestamps
    end
  end
end

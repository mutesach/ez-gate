class CreateDirectories < ActiveRecord::Migration
  def change
    create_table :directories do |t|
      t.column :user_id, :integer, :null => false
      t.column :directory_ref, :string, :limit => 50, :null => false
			t.column :row1, :string, :limit => 100
			t.column :row2, :string, :limit => 100
			t.column :row3, :string, :limit => 100
      t.column :row4, :string, :limit => 100
      t.column :row5, :string, :limit => 100
      t.column :row6, :string, :limit => 100
      t.timestamps
    end
    add_index :directories, :user_id, :name => "idx_directories_user_id"
    add_index :directories, :directory_ref, :name => "idx_directories_directory_ref"
  end
end

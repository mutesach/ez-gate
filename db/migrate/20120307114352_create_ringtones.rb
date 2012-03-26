class CreateRingtones < ActiveRecord::Migration
  def change
    create_table :ringtones do |t|
      t.column :user_id, :integer, :null => false
      t.column :keyword, :string, :limit => 50, :null => false
			t.column :aliases, :string, :limit => 50
			t.column :song_title, :string, :limit => 100
      t.column :artist_name, :string, :limit => 50
      t.column :f_name, :string, :limit => 50
      t.column :f_extension, :string, :limit => 30
      t.column :f_size, :string, :limit => 20
			t.column :f_path, :string, :limit => 100
      t.column :status, :boolean, :default => 0
      t.timestamps
    end
    add_index :ringtones, :user_id, :name => "idx_ringtones_user_id"
    add_index :ringtones, :keyword, :name => "idx_ringtones_keyword"
    add_index :ringtones, :song_title, :name => "idx_ringtones_song_title"
    add_index :ringtones, :artist_name, :name => "idx_ringtones_artist_name"
  end
end

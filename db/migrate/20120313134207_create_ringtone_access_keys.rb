class CreateRingtoneAccessKeys < ActiveRecord::Migration
  def change
    create_table :ringtone_access_keys do |t|
      t.column :ringtone_id, :integer, :null => false
      t.column :key, :string, :limit => 50, :null => false
			t.column :expires_at, :datetime, :default => Time.now() + 86400
      t.column :used_at, :datetime
      t.column :req_status, :string, :limit => 10, :default => "unused"
      t.timestamps
    end
    add_index :ringtone_access_keys, :ringtone_id, :name => "idx_ringtone_acess_keys_ringtone_id"
    add_index :ringtone_access_keys, :key, :name => "idx_ringtone_acess_keys_key"
    add_index :ringtone_access_keys, :req_status, :name => "idx_ringtone_acess_keys_req_status"
  end
end

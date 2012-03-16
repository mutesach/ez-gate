class CreateRingtoneAccessKeys < ActiveRecord::Migration
  def change
    create_table :ringtone_access_keys do |t|
      t.column :ringtone_id, :integer, :null => false
      t.column :hashed_key, :string, :limit => 50, :null => false
			t.column :salt, :string, :limit => 50, :null => false
			t.column :expires_at, :datetime, :default => Time.now() + 86400
      t.column :used_at, :datetime
      t.column :status, :boolean
      t.timestamps
    end
  end
end
